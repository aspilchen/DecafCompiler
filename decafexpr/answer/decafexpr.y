%{
#include <iostream>
#include <ostream>
#include <string>
#include <cstdlib>
#include "decafexpr-defs.h"

int yylex(void);
int yyerror(char *); 

// print AST?
bool printAST = false;

using namespace std;

// this global variable contains all the generated code
static llvm::Module *TheModule;

// this is the method used to construct the LLVM intermediate code (IR)
static llvm::LLVMContext TheContext;
static llvm::IRBuilder<> Builder(TheContext);
// the calls to TheContext in the init above and in the
// following code ensures that we are incrementally generating
// instructions in the right order

// dummy main function
// WARNING: this is not how you should implement code generation
// for the main function!
// You should write the codegen for the main method as 
// part of the codegen for method declarations (MethodDecl)
static llvm::Function *TheFunction = 0;

// we have to create a main function 
llvm::Function *gen_main_def() {
  // create the top-level definition for main
  llvm::FunctionType *FT = llvm::FunctionType::get(llvm::IntegerType::get(TheContext, 32), false);
  llvm::Function *TheFunction = llvm::Function::Create(FT, llvm::Function::ExternalLinkage, "main", TheModule);
  if (TheFunction == 0) {
    throw runtime_error("empty function block"); 
  }
  // Create a new basic block which contains a sequence of LLVM instructions
  llvm::BasicBlock *BB = llvm::BasicBlock::Create(TheContext, "entry", TheFunction);
  // All subsequent calls to IRBuilder will place instructions in this location
  Builder.SetInsertPoint(BB);
  return TheFunction;
}

#include "decafexpr.cc"

%}

%union{
    class Decaf_AST *ast;
    std::string *sval;
 }

%token T_ASSIGN
%token T_BOOLTYPE
%token T_BREAK
%token T_COMMA
%token T_CONTINUE
%token T_DOT
%token T_ELSE
%token T_EXTERN
%token T_FOR
%token T_FUNC
%token T_IF
%token T_INTTYPE
%token T_LCB
%token T_LPAREN
%token T_LSB
%token T_NOT
%token T_NULL
%token T_PACKAGE
%token T_RCB
%token T_RETURN
%token T_RPAREN
%token T_RSB
%token T_SEMICOLON
%token T_STRINGTYPE
%token T_VAR
%token T_VOID
%token T_WHILE

%token<sval> T_ID T_INTCONSTANT T_TRUE T_FALSE 
%token<sval> T_STRINGCONSTANT T_CHARCONSTANT 
%token<ast> T_LEQ T_GEQ T_EQ T_NEQ T_AND T_OR T_PLUS T_MINUS T_MULT T_DIV T_LEFTSHIFT T_RIGHTSHIFT T_MOD T_LT T_GT

%type<sval> field_size
%type<ast> expr_a expr_b expr_c expr_d expr_e expr_f expr_g expr_h number_expr bool_expr method_args statements bool_oper arith_low arith_med
%type<ast> type extern_type method_type 
%type<ast> decafpackage method_arg_list string_constant method_arg statement rvalue assign assignment expression 
%type<ast> method_call if_stmt while_stmt for_stmt return_stmt break_stmt continue_stmt block extern_list extern_defn 
%type<ast> extern extern_param_list extern_param method_decl_list method_decl method method_param_list method_param 
%type<ast> typed_symbol field_decl_list vars else method_block var_list var statement_list assign_list char_const 
%type<ast> extern_params field_decls field_a field_b field_c constant

%left T_MINUS 
%left T_OR

%%

start: program

program: extern_list decafpackage
    { 
        Program_AST *prog = new Program_AST((Node_List_AST *)$1, (Package_AST *)$2); 
		if (printAST) {
			cout << getString(prog) << endl;
		}
        try {
            prog->codegen();
        } 
        catch (std::runtime_error &e) {
            cout << "semantic error: " << e.what() << endl;
            //cout << prog->str() << endl; 
            exit(EXIT_FAILURE);
        }
        delete prog;
    }

extern_list: /* extern_list can be empty */ { Node_List_AST *slist = new Node_List_AST(); $$ = slist; }
					 | extern_defn { 
							Node_List_AST *external_method_list = (Node_List_AST*)$1;
							$$ = external_method_list;
						}
					 ;

extern_defn: extern_defn extern
						 {
							Node_List_AST *extern_list = (Node_List_AST*)$1;
							Decaf_AST *method = $2;
							extern_list->push_back(method);
							$$ = extern_list;
						 }
					 | extern
						 {
							Decaf_AST *method = $1;
							Node_List_AST *extern_list = new Node_List_AST();
							extern_list->push_back(method);
							$$ = extern_list;
						 }
					 ;

extern: T_EXTERN T_FUNC T_ID T_LPAREN extern_param_list T_RPAREN method_type T_SEMICOLON 
				{
					string name = *$3;
					Type_AST *type = static_cast<Type_AST*>$7;
					Node_List_AST *param_list = (Node_List_AST*)$5;
					Function_Decl_AST *method = new Function_Decl_AST(name, type, param_list);
					$$ = method;
				}

extern_param_list: /* Epsilon */ { $$ = new Node_List_AST(); }
								 | extern_params { $$ = $1; }
								 ;
								 
								 
								 
extern_params:extern_params T_COMMA extern_param 
							{
								Node_List_AST *type_list = (Node_List_AST*)$1;
								Decaf_AST *var_def = $3;
								type_list->push_back(var_def);
								$$ = type_list;
							}
						 | extern_param
							{
								Decaf_AST *var_def = $1;
								Node_List_AST *type_list = new Node_List_AST();
								type_list->push_back(var_def);
								$$ = type_list;
							}
						 ;

extern_param: extern_type 
								{
									Type_AST *type = static_cast<Type_AST*>$1;
									Var_Def_AST *var_def = new Var_Def_AST(type);
									$$ = var_def;
								}
							;

extern_type: T_STRINGTYPE { $$ = new String_Type_AST(); }
					 | type { $$ = $1; }
					 ;

decafpackage: T_PACKAGE T_ID T_LCB field_decl_list method_decl_list T_RCB { 
								string name = *$2;
								Node_List_AST *field_list = (Node_List_AST*)$4;
								Node_List_AST *method_list = (Node_List_AST*)$5;
								$$ = new Package_AST(name, field_list, method_list);
								delete $2;
							}
						;

field_decl_list: /* Epsilon */ { $$ = new Node_List_AST(); }
							 | field_decls { $$ = $1; }
							 ;
							 
field_decls: field_decls T_VAR field_a {
							Node_List_AST *field_list_right = (Node_List_AST*)$1;
							Node_List_AST *field_list_left = (Node_List_AST*)$3;
							field_list_left->splice(field_list_right);
							$$ = field_list_left;
						}
					| T_VAR field_a { $$ = $2; }
					| field_decls T_VAR field_c {
							Node_List_AST *field_list_right = (Node_List_AST*)$1;
							Node_List_AST *field_list_left = (Node_List_AST*)$3;
							field_list_left->splice(field_list_right);
							$$ = field_list_left;
							}
					| T_VAR field_c { $$ = $2; }
					;

field_a: T_ID T_COMMA field_a {
					string name = *$1;
					Node_List_AST *field_lst = static_cast<Node_List_AST*>$3;
					Field_Decl_AST *front = static_cast<Field_Decl_AST*>(field_lst->front());
					Type_AST *type = front->type();
					string size = front->size();
					Field_Decl_AST *field = new Field_Decl_AST(name, type, size);
					field_lst->push_front(field);
					$$ = field_lst;
				 }
			 | field_b { $$ = $1; }
			 ;

field_b: T_ID field_size type T_SEMICOLON {
					string name = *$1;
					string size = *$2;
					Type_AST *type = static_cast<Type_AST*>$3;
					Field_Decl_AST *field = new Field_Decl_AST(name, type, size);
					Node_List_AST *field_list = new Node_List_AST();
					field_list->push_front(field);
					$$ = field_list;
				 }
			 | T_ID type T_SEMICOLON {
					string name = *$1;
					Type_AST *type = static_cast<Type_AST*>$2;
					string size = string("Scalar");
					Field_Decl_AST *field = new Field_Decl_AST(name, type, size);
					Node_List_AST *field_list = new Node_List_AST();
					field_list->push_front(field);
					$$ = field_list;
			 }
			 ;
			 
field_c: T_ID type T_ASSIGN constant T_SEMICOLON {
					string name = *$1;
					Type_AST *type = static_cast<Type_AST*>$2;
					Expr_AST *expr = static_cast<Expr_AST*>$4;
					Node_List_AST *field_list = new Node_List_AST();
					Assign_Global_AST *global = new Assign_Global_AST(name, type, expr);
					field_list->push_front(global);
					$$ = field_list;
				 }
			 ;

constant: bool_expr { $$ = $1; }
				| number_expr { $$ = $1; }
				;

field_size: T_LSB T_INTCONSTANT T_RSB {
							string size = *$2;
							string *arr = new string("Array(");
							arr->append(size);
							arr->append(")");
							$$ = arr;
						}
					;

expression: expr_a { $$ = $1; }
					;
					
expr_a: expr_a T_OR expr_b {
				Expr_AST *left = static_cast<Expr_AST*>$1;
				Expr_AST *right = static_cast<Expr_AST*>$3;
				Or_AST *bin_op = new Or_AST(left, right);
				$$ = bin_op;
			 }
			| expr_b { $$ = $1; }
		 ;

expr_b: expr_b T_AND expr_c { 
				Expr_AST *left = static_cast<Expr_AST*>$1;
				Expr_AST *right = static_cast<Expr_AST*>$3;
				And_AST *bin_op = new And_AST(left, right);
				$$ = bin_op;
				}
		 | expr_c { $$ = $1; }
		 ;

expr_c: expr_c bool_oper expr_d{
				Expr_AST *left = static_cast<Expr_AST*>$1;
				Binary_AST* bin_op = static_cast<Binary_AST*>$2;
				Expr_AST *right = static_cast<Expr_AST*>$3;
				bin_op->set_lval(left);
				bin_op->set_rval(right);
				$$ = bin_op;
		 }
		 | expr_d { $$ = $1; }
		 ;

expr_d: expr_d arith_low expr_e{
				Expr_AST* left = static_cast<Expr_AST*>$1;
				Binary_AST* bin_op = static_cast<Binary_AST*>$2;
				Expr_AST* right = static_cast<Expr_AST*>$3;
				bin_op->set_lval(left);
				bin_op->set_rval(right);
				$$ = bin_op;
		 }
		 | expr_e { $$ = $1; }
		 ;

expr_e: expr_e arith_med expr_f {
				Expr_AST* left = static_cast<Expr_AST*>$1;
				Binary_AST* bin_op = static_cast<Binary_AST*>$2;
				Expr_AST* right = static_cast<Expr_AST*>$3;
				bin_op->set_lval(left);
				bin_op->set_rval(right);
				$$ = bin_op;
			 }
		 | expr_f { $$ = $1; }
		 ;

expr_f: T_NOT expr_f {
				Expr_AST *right = static_cast<Expr_AST*>$2;
				Unary_Not_AST *un_op = new Unary_Not_AST(right);
				$$ = un_op;
			 }
		 | expr_g { $$ = $1; }
		 ;
	
expr_g: T_MINUS expr_g {
				Expr_AST *right = static_cast<Expr_AST*>$2;
				Unary_Minus_AST *un_op = new Unary_Minus_AST(right);
				$$ = un_op;
			 }
		 | expr_h { $$ = $1; }
		 ;

expr_h: rvalue { $$ = $1; }
			| number_expr { $$ = $1; }
			| bool_expr { $$ = $1; }
			| method_call { $$ = $1; }
			| char_const { $$ = $1; }
			| T_LPAREN expression T_RPAREN { $$ = $2; }
		  ;
		 
arith_med: T_MULT  { $$ = new Multiply_AST(); }
				 | T_DIV  { $$ = new Divide_AST(); }
				 | T_LEFTSHIFT  { $$ = new Leftshift_AST(); }
				 | T_RIGHTSHIFT  { $$ = new Rightshift_AST(); }
				 | T_MOD  { $$ = new Modulus_AST(); }
				 ;

arith_low: T_PLUS { $$ = new Plus_AST(); }
				 | T_MINUS  { $$ = new Minus_AST(); }
				 ;


rvalue: T_ID {
					string name = *$1;
					Variable_Expr_AST *rvalue = new Variable_Expr_AST(name);
					$$ = rvalue;
				}
			| T_ID T_LSB expression T_RSB {
					string name = *$1;
					Expr_AST *index = static_cast<Expr_AST*>$3;
					Array_Loc_Expr_AST *rvalue = new Array_Loc_Expr_AST(name, index);
					$$ = rvalue;
				}
			;

bool_oper: T_NEQ  { $$ = new Neq_AST(); }
				 | T_LT  { $$ = new Lt_AST(); }
				 | T_GT  { $$ = new Gt_AST(); }
				 | T_LEQ  { $$ = new Leq_AST(); }
				 | T_GEQ  { $$ = new Geq_AST(); }
				 | T_EQ  { $$ = new Eq_AST(); }
				 ;


bool_expr: T_TRUE {
							Bool_AST *expr = new Bool_AST("True");
							$$ = expr;
						}
					| T_FALSE {
							Bool_AST *expr = new Bool_AST("False");
							$$ = expr;
						}
					;
			

	/* Method declarations */

method_decl_list: /* Epsilon */ { $$ = new Node_List_AST(); }
								| method_decl { $$ = $1; }
								;
								
method_decl: method_decl method
									{
										Node_List_AST *method_list = (Node_List_AST*)$1;
										Decaf_AST *method = $2;
										method_list->push_back(method);
										$$ = method_list;
									}
								| method
									{
										Decaf_AST *method = $1;
										Node_List_AST *method_list = new Node_List_AST();
										method_list->push_back(method);
										$$ = method_list;
									}
								;

method: T_FUNC T_ID T_LPAREN method_param_list T_RPAREN method_type method_block
						 {
							string name = *$2;
							Node_List_AST *param_list = (Node_List_AST*)$4;
							Type_AST *type = static_cast<Type_AST*>$6;
							Method_Block_AST *method_blk = static_cast<Method_Block_AST*>$7;
							Method_Decl_AST *method = new Method_Decl_AST(name, type, param_list, method_blk);
							$$ = method;
						 }
					 ;

method_param_list: /* Epsilon */ { $$ = new Node_List_AST(); }
								 |	method_param
									 {
										Node_List_AST *param_list = (Node_List_AST*)$1;
										$$ = param_list;
									 }
								 ;

method_param:  method_param T_COMMA typed_symbol 
							{
								Node_List_AST *param_list = (Node_List_AST*)$1;
								Decaf_AST *type = $3;
								param_list->push_back(type);
								$$ = param_list;
							}
						| typed_symbol
							{
								Decaf_AST *type = $1;
								Node_List_AST *param_list = new Node_List_AST();
								param_list->push_back(type);
								$$ = param_list;
							}
						;

typed_symbol: T_ID method_type
							{
								string name = *$1;
								Type_AST *type = static_cast<Type_AST*>$2;
								Var_Def_AST *var_def = new Var_Def_AST(name, type);
								$$ = var_def;
							}
						;

method_block: T_LCB var_list statement_list T_RCB
							{
								Node_List_AST *var_list = (Node_List_AST*)$2;
								Node_List_AST *statement_list = (Node_List_AST*)$3;
								Method_Block_AST *method_blk = new Method_Block_AST(var_list, statement_list);
								$$ = method_blk;
							}
						;

var_list: /* Epsilon */ { $$ = new Node_List_AST(); }
						| vars
							{
								$$ = $1;
							}
						;

vars: T_VAR var vars
						 {
							Node_List_AST *right_list = (Node_List_AST*)$2;
							Node_List_AST *left_list = (Node_List_AST*)$3;
							left_list->splice(right_list);
							$$ = left_list;
						 }
					 | T_VAR var
						 {
							Decaf_AST *var_list = $2;
							$$ = var_list;
						 }
					 ;

var: T_ID T_COMMA var
						{
							string name = *$1;
							Node_List_AST *var_list = (Node_List_AST*)$3;
							Var_Def_AST *prev = (Var_Def_AST*)var_list->front();
							Type_AST *type = prev->type();
							Var_Def_AST *var = new Var_Def_AST(name, type);
							var_list->push_front(var);
							$$ = var_list;
						}
					| T_ID type T_SEMICOLON
						{ 
							string name = *$1;
							Type_AST *type = static_cast<Type_AST*>$2;
							Var_Def_AST *var = new Var_Def_AST(name, type);
							Node_List_AST *var_list = new Node_List_AST();
							var_list->push_front(var);
							$$ = var_list;
						}
					;

statement_list: /* Epsilon */ { $$ = new Node_List_AST(); }
										 | statements { $$ = $1; }
										 ;


statements: statements statement {
										 Node_List_AST *stmt_list = static_cast<Node_List_AST*>$1;
										 Decaf_AST *stmt = $2;
									 	 stmt_list->push_back(stmt);
									 	 $$ = stmt_list;
									 }
								 | statement {
										 Decaf_AST *stmt = $1;
										 Node_List_AST *stmt_list = new Node_List_AST();
										 stmt_list->push_back(stmt);
										 $$ = stmt_list;
									 }
								 ;


statement: assign T_SEMICOLON { $$ = $1; }
				 | method_call T_SEMICOLON { $$ = $1; }
				 | if_stmt { $$ = $1; }
				 | while_stmt { $$ = $1; }
				 | for_stmt { $$ = $1; }
				 | return_stmt T_SEMICOLON { $$ = $1; }
				 | break_stmt T_SEMICOLON { $$ = $1; }
				 | continue_stmt T_SEMICOLON { $$ = $1; }
				 | block { $$ = $1; }
				 ;

assign: assignment T_ASSIGN expression {
					Assign_AST *assign_stmt = static_cast<Assign_AST*>$1;
					Expr_AST *expr = static_cast<Expr_AST*>$3;
					assign_stmt->set_value(expr);
					$$ = assign_stmt;
				}
			;

assignment: T_ID {
					string name = *$1;
					Assign_Var_AST *assign_stmt = new Assign_Var_AST(name);
					$$ = assign_stmt;
				}
			| T_ID T_LSB expression T_RSB{
					string name = *$1;
					Expr_AST *index = static_cast<Expr_AST*>$3;
					Assign_Array_Loc_AST *assign_stmt = new Assign_Array_Loc_AST(name, index);
					$$ = assign_stmt;
				}
			;

method_call: T_ID T_LPAREN method_arg_list T_RPAREN {
							string id = *$1;
							Node_List_AST *args = static_cast<Node_List_AST*>$3;
							Method_Call_AST *mthd_call = new Method_Call_AST(id, args);
							$$ = mthd_call;
						}
					 ;

method_arg_list: /* Epsilon */ { $$ = new Node_List_AST(); }
							 | method_args { $$ = $1; }
							 ;

method_args: method_args T_COMMA method_arg {
	Node_List_AST *arg_list = static_cast<Node_List_AST*>$1;
	Decaf_AST *arg = $3;
	arg_list->push_back(arg);
	$$ = arg_list;
 }
| method_arg {
	Node_List_AST *arg_list = new Node_List_AST();
	Decaf_AST *arg = $1;
	arg_list->push_back(arg);
	$$ = arg_list;
 }
;

method_arg: expression { $$ = $1; }
					| string_constant { $$ = $1; }
					;

string_constant: T_STRINGCONSTANT {
									string value = *$1;
									String_Const_AST *str = new String_Const_AST(value);
									$$ = str;
								 }
							 ;

char_const: T_CHARCONSTANT {
									string value = *$1;
									int ascii;
									if(value[1] == '\\') {
										switch(value[2]){
										case 'a':
										case 'A':
														ascii = '\a';
														break;
										case 'b':
										case 'B':
														ascii = '\b';
														break;
										case 't':
										case 'T':
														ascii = '\t';
														break;
										case 'n':
										case 'N':
														ascii = '\n';
														break;
										case 'v':
										case 'V':
														ascii = '\v';
														break;
										case 'f':
										case 'F':
														ascii = '\f';
														break;
										case 'r':
										case 'R':
														ascii = '\r';
														break;
										case '\\':
														ascii = '\\';
														break;
										case '\'':
														ascii = '\'';
														break;
										case '"':
														ascii = '"';
														break;
										}
									}
									else {
										ascii = value[1];
									}
									Number_AST *chr = new Number_AST(to_string(ascii));
									$$ = chr;
								}

number_expr: T_INTCONSTANT 
						 {
							string value = *$1;
							Number_AST *number = new Number_AST(value);
							$$ = number;
						 }
					 ;

if_stmt: T_IF T_LPAREN expression T_RPAREN block else {
					Expr_AST *expr = static_cast<Expr_AST*>$3;
					Block_AST *if_blk = static_cast<Block_AST*>$5;
					Block_AST *else_blk = static_cast<Block_AST*>$6;
					If_AST *if_stmt = new If_AST(expr, if_blk, else_blk);
					$$ = if_stmt;
				 }
			 ;

else: /* Epsilon */ { $$ = NULL; }
		| T_ELSE block { $$ = $2; }
		;


while_stmt: T_WHILE T_LPAREN expression T_RPAREN block {
							Expr_AST *condition = static_cast<Expr_AST*>$3;
							Block_AST *blk = static_cast<Block_AST*>$5;
							While_AST *while_stmt = new While_AST(condition, blk);
							$$ = while_stmt;
						}
					;

for_stmt: T_FOR T_LPAREN assign_list T_SEMICOLON expression T_SEMICOLON assign_list T_RPAREN block {
						Node_List_AST *ass_lst = static_cast<Node_List_AST*>$3;
						Expr_AST *expr = static_cast<Expr_AST*>$5;
						Node_List_AST *loop_ass_lst = static_cast<Node_List_AST*>$7;
						Block_AST *blk = static_cast<Block_AST*>$9;
						For_AST *for_stmt = new For_AST(ass_lst, expr, loop_ass_lst, blk);
						$$ = for_stmt;
					}
				;

assign_list: assign_list T_COMMA assign {
							Node_List_AST *ass_lst = static_cast<Node_List_AST*>$1;
							Assign_AST *ass = static_cast<Assign_AST*>$3;
							ass_lst->push_back(ass);
							$$ = ass_lst;
						 }
					 | assign {
							Assign_AST *ass = static_cast<Assign_AST*>$1;
							Node_List_AST *ass_lst = new Node_List_AST();
							ass_lst->push_back(ass);
							$$ = ass_lst;
						}

return_stmt: T_RETURN T_LPAREN expression T_RPAREN {
							Expr_AST *expr = static_cast<Expr_AST*>$3;
							Return_AST *return_stmt = new Return_AST(expr);
							$$ = return_stmt;
						 }
					 | T_RETURN T_LPAREN T_RPAREN {
							Return_AST *return_stmt = new Return_AST();
							$$ = return_stmt;
						 }
					 | T_RETURN {
							Return_AST *return_stmt = new Return_AST();
							$$ = return_stmt;
					 }
					 ;

break_stmt: T_BREAK { $$ = new Break_AST(); }
					;

continue_stmt: T_CONTINUE { $$ = new Continue_AST(); }
						 ;


block: T_LCB var_list statement_list T_RCB {
								Node_List_AST *var_list = (Node_List_AST*)$2;
								Node_List_AST *statement_list = (Node_List_AST*)$3;
								Block_AST *method_blk = new Block_AST(var_list, statement_list);
								$$ = method_blk;
							}
			;

method_type: T_VOID { $$ = new Void_Type_AST(); }
					 | type { $$ = $1; }
					 ;

type: T_INTTYPE { $$ = new Int_Type_AST();; }
		| T_BOOLTYPE { $$ = new Bool_Type_AST();; }
		;


%%

int main() {
  // initialize LLVM
  llvm::LLVMContext &Context = TheContext;
  // Make the module, which holds all the code.
  TheModule = new llvm::Module("Test", Context);
  // parse the input and create the abstract syntax tree
  int retval = yyparse();
  // Validate the generated code, checking for consistency.
  //verifyFunction(*TheFunction);
  // Print out all of the generated code to stderr
  TheModule->print(llvm::errs(), nullptr);
  //TheModule->print(llvm::outs(), nullptr);
  return(retval >= 1 ? EXIT_FAILURE : EXIT_SUCCESS);
}

