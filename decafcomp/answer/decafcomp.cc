/*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~
 * This file is getting way to big. If I had more time and less exams this semester I would have broken this
 * into multiple files. But for the sake of less messing about, sadly just dealing with a giant single file.
 * I would VERY MUCH prefer putting the symbol table definitions in a different file, and splitting headers and bodies.
 * Don't wanna deal with linking new files into the build in this case.
 * 
 * I attempted to handle as much code generation as possible here through the AST nodes. Also making nodes
 * deal with symbol table insertion and deletion to avoid altering the yacc file more than I have to. Also I think it
 * just makes more sense to make the symbol table follow the same style as the Builder module, leaving it global and
 * the nodes will interact with it.
 * :( :(
 *~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~
 */

#include "decafcomp-defs.h"
#include <list>
#include <ostream>
#include <iostream>
#include <sstream>

#ifndef YYTOKENTYPE
#include "decafcomp.tab.h"
#endif

using namespace std;


typedef map<string, llvm::Value*> Table_Scope;

class Symbol_Table {
	list<Table_Scope*> table_list_;

public:
	Symbol_Table() {}

	Table_Scope* get_current_scope(){
		return table_list_.front();
	}
	
	Table_Scope* scope_in() {
		Table_Scope* scope = new Table_Scope();
		table_list_.push_front(scope);
		return scope;
	}

	void scope_out() {
		Table_Scope* scope = get_current_scope();
		table_list_.pop_front();
		delete scope;
	}

	void insert(string key, llvm::Value* value) {
		Table_Scope* scope = table_list_.front();
		pair<string, llvm::Value*> symbol(key, value);
		scope->insert(symbol);
	}

	llvm::Value* get(string key){
		list<Table_Scope*>::iterator table = table_list_.begin();
		list<Table_Scope*>::iterator sentinal = table_list_.end();
		map<string, llvm::Value*>::iterator symbol;
		while(table != sentinal){
			symbol = (*table)->find(key);
			if(symbol != (*table)->end()){
				return symbol->second;
			}
			table++;
		}
		return NULL;
	}
};

static Symbol_Table TheTable;

/// Decaf_AST - Base class for all abstract syntax tree nodes.
class Decaf_AST {
	protected:
		string name_;

		Decaf_AST()
			:name_("") {}

		Decaf_AST(string name)
			:name_(name) {}

	public:
		virtual ~Decaf_AST() {}

		virtual string str() {
			return string("");
		}

		virtual llvm::Value *codegen() = 0;

		string get_name(){
			return name_;
		}
};

string getString(Decaf_AST *d) {
	if (d != NULL) {
		return d->str();
	} else {
		return string("None");
	}
}

template <class T>
string commaList(list<T> vec) {
    string s("");
    for (typename list<T>::iterator i = vec.begin(); i != vec.end(); i++) { 
        s = s + (s.empty() ? string("") : string(",")) + (*i)->str(); 
    }   
    if (s.empty()) {
        s = string("None");
    }   
    return s;
}

template <class T>
llvm::Value *listCodegen(list<T> vec) {
	llvm::Value *val = NULL;
	for (typename list<T>::iterator i = vec.begin(); i != vec.end(); i++) { 
		llvm::Value *j = (*i)->codegen();
		if (j != NULL) { val = j; }
	}	
	return val;
};


/** Node_List_AST
 * List of decaf statements.
 */
class Node_List_AST : public Decaf_AST {
	list<Decaf_AST *> nodes_;

public:
	Node_List_AST() 
		:Decaf_AST() {}
	~Node_List_AST() {
		for (list<Decaf_AST *>::iterator i = nodes_.begin(); i != nodes_.end(); i++) { 
			delete *i;
		}
	}

	int size() {
		return nodes_.size();
	}

	list<Decaf_AST *>::iterator begin() {
		return nodes_.begin();
	}

	list<Decaf_AST *>::iterator end() {
		return nodes_.end();
	}

	Decaf_AST* front() {
		return nodes_.front();
	}

	void splice(Node_List_AST *list) {
		nodes_.splice(nodes_.begin(), list->nodes_);
	}

	void push_front(Decaf_AST *e) {
		nodes_.push_front(e);
	}

	void push_back(Decaf_AST *e) {
		nodes_.push_back(e);
	}
	
	string str() { 
		return commaList<class Decaf_AST *>(nodes_);
	}

	llvm::Value *codegen() { 
		return listCodegen<Decaf_AST *>(nodes_); 
	}
};


/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
 * Types
 */

class Type_AST : public Decaf_AST
{ 
	protected:
		Type_AST()
			:Decaf_AST() {}

	public:
		virtual llvm::Type* gen_type() = 0;
		virtual llvm::Type* gen_global() = 0;
};

class Int_Type_AST : public Type_AST
{
public:
	Int_Type_AST()
		:Type_AST() {}

	string str() { 
		return string("IntType");
	}

	llvm::Value *codegen() { 
		return NULL;
	}

	llvm::Type* gen_type() { 
		return Builder.getInt32Ty();
	}

	llvm::Type* gen_global() {
		return llvm::IntegerType::get(TheContext, 32);
	}
};

class Bool_Type_AST : public Type_AST
{
	public:
		Bool_Type_AST()
			:Type_AST() {}

	string str() { 
		return string("BoolType");
	}

	llvm::Value *codegen() { 
		return NULL;
	}

	llvm::Type *gen_type() { 
		return Builder.getInt1Ty();
	}

	llvm::Type *gen_global() {
		return llvm::IntegerType::get(TheContext, 1);
	}
};

class String_Type_AST : public Type_AST
{
public:
	String_Type_AST()
		:Type_AST() {}

	string str() { 
		return string("StringType");
	}

	llvm::Value *codegen() { 
		return NULL;
	}

	llvm::Type *gen_type() { 
		return Builder.getInt8PtrTy();
	}

	llvm::Type *gen_global() {
		return Builder.getInt8PtrTy();
	}
};

class Void_Type_AST : public Type_AST
{
public:
	Void_Type_AST()
		:Type_AST() {}

	string str() { 
		return string("VoidType");
	}

	llvm::Value *codegen() { 
		return NULL;
	}

	llvm::Type *gen_type() { 
		return Builder.getVoidTy();
	}

	llvm::Type *gen_global() {
		return NULL;
	}
};

/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
 * Expressions
 */

/*** Superclass for all expressions.
 */
class Expr_AST : public Decaf_AST
{
	protected:
		string value_;

		Expr_AST()
			:Decaf_AST() {}

		Expr_AST(string name)
			:Decaf_AST(name) {}

	public:
	void set_value(string value){
		value_ = value;
	}

	string get_value(){
		return value_;
	}
};

/** Number_Expr_AST
 * Number expression.
 */
class Number_AST : public Expr_AST
{
public:
	Number_AST(string value) 
		:Expr_AST(value) {
			value_ = value;
		}

	~Number_AST() { }

	string str() { 
		return string("NumberExpr(")  + value_ +  ")";
	}

	llvm::Value *codegen() {
		long value = 0;
		if(value_.compare(0, 2, "0x") == 0 || value_.compare(0, 2, "0X") == 0){
			stringstream ss;
			ss << hex << value_.substr(2);
			ss >> value;
		}
		else{
			value = stol(value_);
		}
		return Builder.getInt32(value);
	}
};

/** Bool_AST
 * Boolean expression.
 */
class Bool_AST : public Expr_AST
{
public:
	Bool_AST(string value) 
		:Expr_AST() {
			value_ = value;
		}

	~Bool_AST() { }

	string str() { 
		return string("BoolExpr(")  + value_ +  ")";
	}

	llvm::Value *codegen() {
		int value = value_.compare("False");
		return Builder.getInt1(value);
	}
};

/** Binary_AST
 * Binary expression.
 */
class Binary_AST : public Expr_AST
{
	protected:
		string operator_;
		Expr_AST *left_val_;
		Expr_AST *right_val_;
		virtual llvm::Value* build(llvm::Value* lval, llvm::Value* rval) = 0;

public:
	Binary_AST(string op) 
		:Expr_AST(), operator_(op), left_val_(NULL), right_val_(NULL) {}

	Binary_AST(string op, Expr_AST *lval, Expr_AST *rval) 
		:Expr_AST(), operator_(op), left_val_(lval), right_val_(rval) {}

	~Binary_AST() {
		delete left_val_;
		delete right_val_;
	}

	void set_lval(Expr_AST* lval){
		left_val_ = lval;
	}

	void set_rval(Expr_AST* rval){
		right_val_ = rval;
	}

	string str() { 
		return string("BinaryExpr(")  + operator_ + "," + getString(left_val_) + "," + getString(right_val_) + ")";
	}

	llvm::Value* codegen() {
		llvm::Value* lval = left_val_->codegen();
		llvm::Value* rval = right_val_->codegen();
		return build(lval, rval);
	}
};

/** Plus_AST
 * Binary expression.
 */
class Plus_AST : public Binary_AST
{
	private:
		llvm::Value* build(llvm::Value* lval, llvm::Value* rval) {
			return Builder.CreateAdd(lval, rval, "tmpAdd");
		}
	public:
		Plus_AST() 
			:Binary_AST("Plus") {}

		Plus_AST(Expr_AST *lval, Expr_AST *rval) 
			:Binary_AST("Plus", lval, rval) {}
};

/** Subtract_AST
 * Binary expression.
 */
class Minus_AST : public Binary_AST
{
	private:
		llvm::Value* build(llvm::Value* lval, llvm::Value* rval){
			return Builder.CreateSub(lval, rval, "tmpSub");
		}
	public:
		Minus_AST() 
			:Binary_AST("Minus") {}

		Minus_AST(Expr_AST *lval, Expr_AST *rval) 
			:Binary_AST("Minus", lval, rval) {}
};

/** Multiply_AST
 * Binary expression.
 */
class Multiply_AST : public Binary_AST
{
	private:
		llvm::Value* build(llvm::Value* lval, llvm::Value* rval){
			return Builder.CreateMul(lval, rval, "tempMul");
		}
	public:
		Multiply_AST() 
			:Binary_AST("Mult") {}

		Multiply_AST(Expr_AST *lval, Expr_AST *rval) 
			:Binary_AST("Mult", lval, rval) {}
};

/** Divide_AST
 * Binary expression.
 */
class Divide_AST : public Binary_AST
{
	private:
		llvm::Value* build(llvm::Value* lval, llvm::Value* rval){
			return Builder.CreateSDiv(lval, rval, "tempDiv");
		}
	public:
		Divide_AST() 
			:Binary_AST("Div") {}

		Divide_AST(Expr_AST *lval, Expr_AST *rval) 
			:Binary_AST("Div", lval, rval) {}
};

/** Shift_Left_AST
 * Binary expression.
 */
class Leftshift_AST : public Binary_AST
{
	private:
		llvm::Value* build(llvm::Value* lval, llvm::Value* rval){
			return Builder.CreateShl(lval, rval, "tempShl");
		}
	public:
		Leftshift_AST() 
			:Binary_AST("Leftshift") {}

		Leftshift_AST(Expr_AST *lval, Expr_AST *rval) 
			:Binary_AST("Leftshift", lval, rval) {}
};

/** Shift_Right_AST
 * Binary expression.
 */
class Rightshift_AST : public Binary_AST
{
	private:
		llvm::Value* build(llvm::Value* lval, llvm::Value* rval){
			return Builder.CreateLShr(lval, rval, "tempShr");
		}
	public:
		Rightshift_AST() 
			:Binary_AST("Rightshift") {}

		Rightshift_AST(Expr_AST *lval, Expr_AST *rval) 
			:Binary_AST("Rightshift", lval, rval) {}
};

/** Multiply_AST
 * Binary expression.
 */
class Modulus_AST : public Binary_AST
{
	private:
		llvm::Value* build(llvm::Value* lval, llvm::Value* rval){
			return Builder.CreateSRem(lval, rval, "tempSRem");
		}
	public:
		Modulus_AST() 
			:Binary_AST("Mod") {}

		Modulus_AST(Expr_AST *lval, Expr_AST *rval) 
			:Binary_AST("Mod", lval, rval) {}
};

/** Lt_AST
 * Binary expression.
 */
class Lt_AST : public Binary_AST
{
	private:
		llvm::Value* build(llvm::Value* lval, llvm::Value* rval){
			return Builder.CreateICmpSLT(lval, rval, "tempLt");
		}
	public:
		Lt_AST() 
			:Binary_AST("Lt") {}

		Lt_AST(Expr_AST *lval, Expr_AST *rval) 
			:Binary_AST("Lt", lval, rval) {}
};

/** Gt_AST
 * Binary expression.
 */
class Gt_AST : public Binary_AST
{
	private:
		llvm::Value* build(llvm::Value* lval, llvm::Value* rval){
			return Builder.CreateICmpSGT(lval, rval, "tempGt");
		}
	public:
		Gt_AST() 
			:Binary_AST("Gt") {}

		Gt_AST(Expr_AST *lval, Expr_AST *rval) 
			:Binary_AST("Gt", lval, rval) {}
};

/** Leq_AST
 * Binary expression.
 */
class Leq_AST : public Binary_AST
{
	private:
		llvm::Value* build(llvm::Value* lval, llvm::Value* rval){
			return Builder.CreateICmpSLE(lval, rval, "tempLe");
		}
	public:
		Leq_AST() 
			:Binary_AST("Leq") {}

		Leq_AST(Expr_AST *lval, Expr_AST *rval) 
			:Binary_AST("Leq", lval, rval) {}
};

/** Geq_AST
 * Binary expression.
 */
class Geq_AST : public Binary_AST
{
	private:
		llvm::Value* build(llvm::Value* lval, llvm::Value* rval){
			return Builder.CreateICmpSGE(lval, rval, "temp");
		}
	public:
		Geq_AST() 
			:Binary_AST("Geq") {}

		Geq_AST(Expr_AST *lval, Expr_AST *rval) 
			:Binary_AST("Geq", lval, rval) {}
};

/** And_AST
 * Binary expression.
 */
class And_AST : public Binary_AST
{
	private:
		llvm::Value* build(llvm::Value* lval, llvm::Value* rval){
			return NULL;
		}
	public:
		And_AST() 
			:Binary_AST("And") {}

		And_AST(Expr_AST *lval, Expr_AST *rval) 
			:Binary_AST("And", lval, rval) {}

		llvm::Value* codegen(){
			llvm::Value* lval = left_val_->codegen();
			llvm::Type* lval_type = lval->getType();
			llvm::BasicBlock* cur_block = Builder.GetInsertBlock();
			llvm::Function* function = cur_block->getParent();
			llvm::BasicBlock* noSC = llvm::BasicBlock::Create(TheContext, "noSC", function);
			llvm::BasicBlock* scEnd = llvm::BasicBlock::Create(TheContext, "scEnd", function);
			Builder.CreateCondBr(lval, noSC, scEnd);
			Builder.SetInsertPoint(noSC);
			llvm::Value* rval = right_val_->codegen();
			llvm::Value* tmp_and = Builder.CreateAnd(lval, rval, "tempAnd");
			Builder.CreateBr(scEnd);
			llvm::BasicBlock* recursed_block = Builder.GetInsertBlock();
			Builder.SetInsertPoint(scEnd);
			llvm::PHINode* val = Builder.CreatePHI(lval_type, 2, "phival");
			val->addIncoming(lval, cur_block);
			val->addIncoming(tmp_and, recursed_block);
			return val;
		}
};

/** Or_AST
 * Binary expression.
 */
class Or_AST : public Binary_AST
{
	private:
		llvm::Value* build(llvm::Value* lval, llvm::Value* rval){
			return NULL;
		}

	public:
		Or_AST() 
			:Binary_AST("Or") {}

		Or_AST(Expr_AST *lval, Expr_AST *rval) 
			:Binary_AST("Or", lval, rval) {}

		llvm::Value* codegen(){
			llvm::Value* lval = left_val_->codegen();
			llvm::Type* lval_type = lval->getType();
			llvm::BasicBlock* cur_block = Builder.GetInsertBlock();
			llvm::Function* function = cur_block->getParent();
			llvm::BasicBlock* noSC = llvm::BasicBlock::Create(TheContext, "noSC", function);
			llvm::BasicBlock* scEnd = llvm::BasicBlock::Create(TheContext, "scEnd", function);
			Builder.CreateCondBr(lval, scEnd, noSC);

			Builder.SetInsertPoint(noSC);
			llvm::Value* rval = right_val_->codegen();
			llvm::Value* tmp_or = Builder.CreateOr(lval, rval, "tempOr");
			llvm::BasicBlock* recursed_block = Builder.GetInsertBlock();
			Builder.CreateBr(scEnd);

			Builder.SetInsertPoint(scEnd);
			llvm::PHINode* val = Builder.CreatePHI(lval_type, 2, "phival");
			val->addIncoming(lval, cur_block);
			val->addIncoming(tmp_or, recursed_block);
			return val;
		}
};

/** Eq_AST
 * Binary expression.
 */
class Eq_AST : public Binary_AST
{
	private:
		llvm::Value* build(llvm::Value* lval, llvm::Value* rval){
			return Builder.CreateICmpEQ(lval, rval, "tempEq");
		}
	public:
		Eq_AST() 
			:Binary_AST("Eq") {}

		Eq_AST(Expr_AST *lval, Expr_AST *rval) 
			:Binary_AST("Eq", lval, rval) {}
};

/** Neq_AST
 * Binary expression.
 */
class Neq_AST : public Binary_AST
{
	private:
		llvm::Value* build(llvm::Value* lval, llvm::Value* rval){
			return Builder.CreateICmpNE(lval, rval, "tempNe");
		}
	public:
		Neq_AST() 
			:Binary_AST("Neq") {}

		Neq_AST(Expr_AST *lval, Expr_AST *rval) 
			:Binary_AST("Neq", lval, rval) {}
};


/** Unary_AST
 * Unary expression.
 */
class Unary_AST : public Expr_AST
{
	protected:
	string operator_;
	Expr_AST *value_;

	virtual llvm::Value* build(llvm::Value* value) = 0;

	Unary_AST(string op) 
		:Expr_AST(), operator_(op), value_(NULL) {}

	Unary_AST(string op, Expr_AST *value) 
		:Expr_AST(), operator_(op), value_(value) {}

	public:
	~Unary_AST() {
		delete value_;
	}

	string str() { 
		return string("UnaryExpr(")  + operator_ + "," + getString(value_) + ")";
	}

	llvm::Value *codegen() {
		llvm::Value *rval = value_->codegen();
		return build(rval);
	}
};

/** Unary_Minus_AST
 * Unary expression.
 */
class Unary_Minus_AST : public Unary_AST
{
	virtual llvm::Value* build(llvm::Value* value) {
			return Builder.CreateNeg(value, "tmpNeg");
	}
	public:
	Unary_Minus_AST()
		:Unary_AST("UnaryMinus") {}

	Unary_Minus_AST(Expr_AST* value)
		:Unary_AST("UnaryMinus", value) {}
};

/** Unary_Not_AST
 * Unary expression.
 */
class Unary_Not_AST : public Unary_AST
{
	virtual llvm::Value* build(llvm::Value* value) {
			return Builder.CreateNot(value, "tmpNot");
	}
	public:
	Unary_Not_AST()
		:Unary_AST("Not") {}

	Unary_Not_AST(Expr_AST* value)
		:Unary_AST("Not", value) {}
};


/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
 * Constants
 */

class String_Const_AST : public Expr_AST
{
	string value_;

	public:
	String_Const_AST(string value) 
		:Expr_AST(), value_(value) {}

	~String_Const_AST() { }

	string str() {
		return string("StringConstant(") + value_ + ")";
	}

	llvm::Value *codegen() {
		string str = value_;
		str.erase(str.length() - 1, 1);
		str.erase(0, 1);
		int index = str.find('\\');
		int replace = 0;
		int replace_things = 0;
		while(index != string::npos){
			replace = 1;
			replace_things = 1;
				char c = str[index + 1];
				string rep;
				switch(c) {
					case 'a':
					case 'A':
						rep = '\a';
						break;
					case 'b':
					case 'B':
						rep = '\b';
						break;
					case 't':
					case 'T':
						rep = '\t';
						break;
					case 'n':
					case 'N':
						rep = '\n';
						break;
					case 'v':
					case 'V':
						rep = '\v';
						break;
					case 'f':
					case 'F':
						rep = '\f';
						break;
					case 'r':
					case 'R':
						rep = '\r';
						break;
						break;
					case '\'':
						rep = '\'';
						break;
					case '"':
						rep = '\"';
						break;
					case '\\':
						rep = '\\';
						break;
					default:
						replace = 0;
						break;
				}
				if(replace){
					str.replace(index, 2, rep);
				}
				else{
					index++;
				}
				index = str.find('\\', index);
		}
		const char* value = str.c_str();
		llvm::GlobalVariable *GS = Builder.CreateGlobalString(value, "globalstring");
    return Builder.CreateConstGEP2_32(GS->getValueType(), GS, 0, 0, "cast");
	}
};

/*** Method_Block_AST
*/
class Method_Block_AST : public Decaf_AST 
{
	Node_List_AST *var_list_;
	Node_List_AST *statement_list_;

	public:
	Method_Block_AST(Node_List_AST *var_list, Node_List_AST *statement_list) 
		:Decaf_AST(), var_list_(var_list), statement_list_(statement_list) {}

	~Method_Block_AST() { 
		if (var_list_ != NULL) { delete var_list_; }
		if (statement_list_ != NULL) { delete statement_list_; }
	}

	string str() { 
		return string("MethodBlock(") + getString(var_list_) + "," + getString(statement_list_) + ")";
	}

	llvm::Value *codegen() {
		TheTable.scope_in();
		llvm::BasicBlock *cur_block = Builder.GetInsertBlock();
		llvm::Function *function = Builder.GetInsertBlock()->getParent();
		llvm::Type* return_type = function->getReturnType();

		llvm::Function::arg_iterator arg_iter = function->arg_begin();
		llvm::Function::arg_iterator arg_end = function->arg_end();
		while(arg_iter != arg_end){

			llvm::AllocaInst* alloca = Builder.CreateAlloca(arg_iter->getType(), nullptr, arg_iter->getName());
			TheTable.insert(arg_iter->getName(), alloca);
			llvm::Value* store = Builder.CreateStore(arg_iter, alloca);
			
			arg_iter++;
		}

		if(var_list_ != NULL) {
			var_list_->codegen();
		}
		if(statement_list_ != NULL) {
			statement_list_->codegen();
		}

		if(return_type->isVoidTy()){
			Builder.CreateRet(nullptr);
		}
		else if(return_type->isIntegerTy(32)){
			Builder.CreateRet(llvm::ConstantInt::get(TheContext, llvm::APInt(32, 0)));
		}
		else if(return_type->isIntegerTy(1)){
			Builder.CreateRet(llvm::ConstantInt::get(TheContext, llvm::APInt(1, 0)));
		}
		TheTable.scope_out();
		return NULL;
	}
};

typedef pair<Method_Block_AST*, llvm::BasicBlock*> Block_Stack_Element;

class Method_Block_Stack {
	list<Block_Stack_Element> stack_;
	
	public:
		Method_Block_Stack() {}
		
		void push(Method_Block_AST* block_ast, llvm::BasicBlock* block_llvm){
			Block_Stack_Element element(block_ast, block_llvm);
			stack_.push_front(element);
		}

		void pop(){
			stack_.pop_front();
		}

		bool empty(){
			return stack_.empty();
		}

		Block_Stack_Element front(){
			return stack_.front();
		}
};

static Method_Block_Stack block_stack;

/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
 * Variables
 */

/*** Var_Def_AST
*/
class Var_Def_AST : public Decaf_AST
{
	Type_AST* type_;
	Expr_AST* value_;

	public:
	Var_Def_AST(Type_AST *type) 
		:Decaf_AST(), type_(type) {}

	Var_Def_AST(string name, Type_AST *type) 
		:Decaf_AST(name), type_(type) {}

	~Var_Def_AST() { }

	Type_AST* type() {
		return type_;
	};

	string str() { 
		string ret_string = "VarDef(";
		if(name_.length() > 0) {
			ret_string += name_ + ",";
		}
		ret_string += type_->str() + ")";
		return string(ret_string);
	}

	void set_value(Expr_AST* value){
		value_ = value;
	}

	Expr_AST* get_value(){
		return value_;
	}

	llvm::Value* codegen() {
		llvm::AllocaInst* alloca;
		llvm::Type* type = type_->gen_global();
		alloca = Builder.CreateAlloca(type, nullptr, name_.c_str());

		if(name_.length() != 0){
            if(type->isIntegerTy(32)){
                Builder.CreateStore(Builder.getInt32(0), alloca);
            }
            else{
                Builder.CreateStore(Builder.getInt1(0), alloca);
            }
			TheTable.insert(name_, alloca);
		}
		return alloca;
	}
};

/*** Array_AST
*/
class Array_AST : public Decaf_AST
{
	string size_;

	public:
	Array_AST(string size) 
		:Decaf_AST(), size_(size) {}

	~Array_AST() { }

	string str() { 
		return string("Array(")  + size_ + ")";
	}

	llvm::Value *codegen() {
		return NULL;
	}
};

/*** Field_Decl_AST
*/
class Field_Decl_AST : public Decaf_AST
{
	Type_AST *type_;
	string size_;

	public:
	Field_Decl_AST(string name, Type_AST *type) 
		:Decaf_AST(name), type_(type), size_("") {}

	Field_Decl_AST(string name, Type_AST *type, string size) 
		:Decaf_AST(name), type_(type), size_(size) {}

	~Field_Decl_AST() { }

	Type_AST* type() { return type_; }
	string size() { return size_; }

	string str() { 
        string output("FieldDecl("  + name_ + "," + type_->str() + ",");
        if(size_.compare("0") == 0){
            output.append("Scalar)");
        }
        else{
            output.append("ArrayType(" + size_ + "))");
        }
		return output;
	}

	llvm::Value *codegen() {
        llvm::Type* type = type_->gen_type();
        llvm::GlobalVariable* field = NULL;
        int size = stoi(size_);
        if(size > 0){
            llvm::ArrayType* array = llvm::ArrayType::get(type, size);
            llvm::Constant* zero_init = llvm::Constant::getNullValue(array);
            field = new llvm::GlobalVariable(
                    *TheModule,
                    array,
                    false,
                    llvm::GlobalValue::ExternalLinkage,
                    zero_init,
                    name_
                    );
        }
        else{
            field = new llvm::GlobalVariable(
                    *TheModule,
                    type,
                    false,
                    llvm::GlobalValue::InternalLinkage,
                    Builder.getInt32(0),
                    name_
                    );
        }
        TheTable.insert(name_, field);
        return field;
    }
};

/*** Assign_Global_AST
*/
class Assign_Global_AST : public Decaf_AST
{
	Type_AST *type_;
	Expr_AST *value_;

	public:
	Assign_Global_AST(string name, Type_AST *type, Expr_AST *value) 
		:Decaf_AST(name), type_(type), value_(value) {}

	~Assign_Global_AST() { }

	string str() { 
		return string("AssignGlobalVar(")  + name_ + "," + type_->str() + "," + getString(value_) + ")";
	}

	llvm::Value *codegen() {
        llvm::GlobalVariable* field = NULL;
        llvm::Type* type = type_->gen_global();
        llvm::Constant* value = llvm::dyn_cast<llvm::Constant>(value_->codegen());
        field = new llvm::GlobalVariable(
                *TheModule,
                type,
                false,
                llvm::GlobalValue::InternalLinkage,
                value,
                name_
                );
        TheTable.insert(name_, field);
        return field;
	}
};


/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
 * Methods
 */

/*** Method_Decl_AST
*/
class Method_Decl_AST : public Decaf_AST
{
	Type_AST *return_type_;
	Node_List_AST *param_list_;
	Method_Block_AST *block_;

	public:
	Method_Decl_AST(string name, Type_AST *return_type, Node_List_AST *param_list, Method_Block_AST *block) 
		:Decaf_AST(name), return_type_(return_type), param_list_(param_list), block_(block) { }

	~Method_Decl_AST() { 
		if(param_list_ != NULL) {
			delete param_list_;
		}
	}

	string str() { 
		return string("Method(") + name_ + "," + return_type_->str() + "," + getString(param_list_) + "," + getString(block_) + ")";
	}

	llvm::Value *codegen() {
		std::vector<llvm::Type *> args;
		llvm::Type *return_type = return_type_->gen_type();
		Decaf_AST* param_ast = NULL;
		Var_Def_AST *var_def = NULL;
		list<Decaf_AST*>::iterator i = param_list_->begin();
		list<Decaf_AST*>::iterator sentinal = param_list_->end();
		while(i != sentinal){
			param_ast = *i;
			var_def = static_cast<Var_Def_AST*>(param_ast);
			Type_AST *type = var_def->type();
			llvm::Type *arg = type->gen_type();
			args.push_back(arg);
			i++;
		}
		llvm::Function* function = llvm::Function::Create(
				llvm::FunctionType::get(return_type, args, false),
				llvm::Function::ExternalLinkage,
				name_,
				TheModule
				);
		llvm::Function::arg_iterator arg_iter = function->arg_begin();
		llvm::Function::arg_iterator arg_end = function->arg_end();
		i = param_list_->begin();
		while(arg_iter != arg_end){
			param_ast = *i;
			var_def = static_cast<Var_Def_AST*>(param_ast);
			arg_iter->setName(var_def->get_name());
			arg_iter++;
			i++;
		}
		llvm::BasicBlock* block_llvm = llvm::BasicBlock::Create(TheContext, "entry", function);
		TheTable.insert(name_, function);
		block_stack.push(block_, block_llvm);
		return function;
	}
};

/*** Method_Call_AST
*/
class Method_Call_AST : public Expr_AST
{
	Node_List_AST *arg_list_;

	std::vector<llvm::Value *> generate_args(llvm::Function* callee){
		std::vector<llvm::Value *> args;
		llvm::Value* arg = NULL;
		Decaf_AST* arg_ast = NULL;
		llvm::PointerType* param_type = NULL;
		llvm::PointerType* arg_type = NULL;
		llvm::IntegerType* param_type_int = NULL;
		llvm::IntegerType* arg_type_int = NULL;

		list<Decaf_AST*>::iterator arg_i = arg_list_->begin();
		llvm::Function::arg_iterator param_i = callee->arg_begin();
		list<Decaf_AST*>::iterator sentinal = arg_list_->end();
		while(arg_i != sentinal){
			arg_ast = *arg_i;
			arg = arg_ast->codegen();
			param_type = llvm::dyn_cast<llvm::PointerType>(param_i->getType());
			arg_type = llvm::dyn_cast<llvm::PointerType>(arg->getType());
			param_type_int = llvm::dyn_cast<llvm::IntegerType>(param_i->getType());
			arg_type_int = llvm::dyn_cast<llvm::IntegerType>(arg->getType());
			if (param_type != NULL){
				if (param_type == arg_type){
					args.push_back(arg);
				}
			}
			else if(param_type_int != NULL){
				if(arg_type_int != NULL){
					if(param_type_int->getBitWidth() == 32 && arg_type_int->getBitWidth() == 1){
						arg = Builder.CreateZExt(arg, Builder.getInt32Ty(), "arg");
						args.push_back(arg);
					}
					else if(param_type_int->getBitWidth() == arg_type_int->getBitWidth()){
						args.push_back(arg);
					}
				}
			}
			arg_i++;
			param_i++;
		}
		return args;
	}


	public:
	Method_Call_AST(string name, Node_List_AST *arg_list) 
		:Expr_AST(name), arg_list_(arg_list) { }

	~Method_Call_AST() { 
		if(arg_list_ != NULL)
		{
			delete arg_list_;
		}
	}

	string str() { 
		return string("MethodCall(") + name_ + "," + getString(arg_list_) + ")";
	}

	llvm::Value *codegen() {
		llvm::Value* callee_value = TheTable.get(name_);
		llvm::Function* callee = static_cast<llvm::Function*>(callee_value);
		std::vector<llvm::Value *> args = generate_args(callee);
		bool isVoid = callee->getReturnType()->isVoidTy();
		llvm::Value *val = Builder.CreateCall(
				callee,
				args,
				isVoid ? "" : "calltmp");
		return val;
	}
};

/*** Variable_Expr_AST
*/
class Variable_Expr_AST : public Expr_AST
{
	public:
		Variable_Expr_AST(string name) 
			:Expr_AST(name) { }

		~Variable_Expr_AST() { }

		string str() { 
			return string("VariableExpr(") + name_ + ")";
		}

		llvm::Value *codegen() {
			llvm::Value* value = TheTable.get(name_);
			return Builder.CreateLoad(value, name_);

		}
};

/** Array_Loc_Expr_AST
*/
class Array_Loc_Expr_AST : public Expr_AST
{
	Expr_AST *index_;

	public:
	Array_Loc_Expr_AST(string name, Expr_AST *index) 
		:Expr_AST(name), index_(index) { }

	~Array_Loc_Expr_AST() {
		if(index_ != NULL) {
			delete index_;
		}
	}

	string str() { 
		return string("ArrayLocExpr(") + name_ + "," + getString(index_) + ")";
	}

	llvm::Value *codegen() {
        llvm::Value* value = TheTable.get(name_);
        llvm::Value* array_addr = Builder.CreateStructGEP(value, 0, "arrayAddr");
        llvm::Value* index = index_->codegen();
				llvm::Type* index_type = index->getType();
				if(index_type->isIntegerTy(1)){
					throw runtime_error("Illegal index");
				}
        llvm::Value* array_index = Builder.CreateGEP(Builder.getInt32Ty(), array_addr, index, "arrayIndex");
        return  Builder.CreateLoad(array_index, "loadTmp");
	}
};


/*** Function_Decl_AST
*/
class Function_Decl_AST : public Expr_AST
{
	Type_AST *type_;
	Node_List_AST *param_list_;

	public:
	Function_Decl_AST(string name, Type_AST *type, Node_List_AST *params) 
		:Expr_AST(name), type_(type), param_list_(params) { }

	~Function_Decl_AST() {
		if(param_list_ != NULL) {
			delete param_list_;
		}
	}

	string str() { 
		return string("ExternFunction(") + name_ + "," + type_->str() + "," + getString(param_list_) + ")";
	}

	llvm::Value *codegen() {
		std::vector<llvm::Type *> args;
		llvm::Type *return_type = type_->gen_type();
		Decaf_AST* param_ast = NULL;
		Var_Def_AST *var_def = NULL;

		list<Decaf_AST*>::iterator i = param_list_->begin();
		list<Decaf_AST*>::iterator sentinal = param_list_->end();
		while(i != sentinal){
			param_ast = *i;
			var_def = static_cast<Var_Def_AST*>(param_ast);
			Type_AST *type = var_def->type();
			llvm::Type *arg = type->gen_type();
			args.push_back(arg);
			i++;
		}
		llvm::Function* function = llvm::Function::Create(
				llvm::FunctionType::get(return_type, args, false),
				llvm::Function::ExternalLinkage,
				name_,
				TheModule
				);
		TheTable.insert(name_, function);
		return function;
	}
};

/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
 * Statements
 */

/*** Stmt_AST
*/
class Stmt_AST : public Decaf_AST
{
	protected:
		Stmt_AST()
			:Decaf_AST() {}

		Stmt_AST(string name)
			:Decaf_AST(name) {}
};

/** Assign_AST
*/
class Assign_AST : public Stmt_AST
{
	protected:
		Expr_AST *value_;

	public:
		Assign_AST(string name) 
			:Stmt_AST(name) { }

		~Assign_AST(){
			if(value_ != NULL) {
				delete value_;
			}
		}

		void set_value(Expr_AST *value) { 
			value_ = value;
		}
};

/*** Assign_Var_AST
*/
class Assign_Var_AST : public Assign_AST
{
	public:
		Assign_Var_AST(string name) 
			:Assign_AST(name) { }

		~Assign_Var_AST() { }

		string str() { 
			return string("AssignVar(") + name_ + "," + getString(value_) + ")";
		}

		llvm::Value *codegen() {
			llvm::Value* rval = value_->codegen();
			llvm::Value* lval = TheTable.get(name_);
			llvm::AllocaInst* alloca = static_cast<llvm::AllocaInst*>(lval);
			const llvm::PointerType *rval_type = rval->getType()->getPointerTo();
			if(alloca->getType() == rval_type){
				Builder.CreateStore(rval, alloca);
			}
			return lval;
		}
};

/*** Assign_Array_Loc_AST
*/
class Assign_Array_Loc_AST : public Assign_AST
{
	Expr_AST *index_;

	public:
	Assign_Array_Loc_AST(string name, Expr_AST *index) 
		:Assign_AST(name), index_(index) { }

	~Assign_Array_Loc_AST() {
		if(index_ != NULL) {
			delete index_;
		}
	}

	string str() { 
		return string("AssignArrayLoc(") + name_ + "," + getString(index_) + "," + getString(value_) + ")";
	}

	llvm::Value *codegen() {
        llvm::Value* value = TheTable.get(name_);
        llvm::GlobalVariable* global = llvm::dyn_cast<llvm::GlobalVariable>(value);
        llvm::Type* type = global->getType();
        llvm::Value *ArrayLoc = Builder.CreateStructGEP(global, 0, "arrayloc");
        llvm::Value *Index = index_->codegen();
        llvm::Value *ArrayIndex = Builder.CreateGEP(Builder.getInt32Ty(), ArrayLoc, Index, "arrayindex");
        llvm::Value* rval = value_->codegen();
        return  Builder.CreateStore(rval, ArrayIndex);
	}
};



/*** Block_AST
*/
class Block_AST : public Stmt_AST
{
	Node_List_AST *var_list_;
	Node_List_AST *statement_list_;
	public:
	Block_AST(Node_List_AST *var_list, Node_List_AST *statement_list) 
		:Stmt_AST(), var_list_(var_list), statement_list_(statement_list) {}

	~Block_AST() { 
		if (var_list_ != NULL) { delete var_list_; }
		if (statement_list_ != NULL) { delete statement_list_; }
	}

	string str() { 
		return string("Block(") + getString(var_list_) + "," + getString(statement_list_) + ")";
	}

	llvm::Value *codegen() {
		TheTable.scope_in();
		llvm::Value* val = NULL;
		if(var_list_ != NULL) {
			val = var_list_->codegen();
		}
		if(statement_list_ != NULL) {
			val = statement_list_->codegen();
		}
		TheTable.scope_out();
		return val;
	}
};

/*** IfAST
*/
class If_AST : public Stmt_AST
{
	Expr_AST *condition_;
	Block_AST *block_;
	Block_AST *else_block_;
	public:
	If_AST(Expr_AST *condition, Block_AST *blk, Block_AST *else_blk) 
		:Stmt_AST(),  condition_(condition), block_(blk), else_block_(else_blk) { }

	~If_AST() {
		if( condition_ != NULL) {
			delete condition_;
		}
		if( block_ != NULL) {
			delete block_;
		}
		if( else_block_ != NULL) {
			delete else_block_;
		}
	}

	string str()
	{ 
		if(else_block_ != NULL){
			return string("IfStmt(") + getString(condition_) + "," + getString(block_) + "," + getString(else_block_) + ")";
		}
		else{
			return string("IfStmt(") + getString(condition_) + "," + getString(block_) + "," + getString(else_block_) + ")";
		}
	}

	llvm::Value *codegen() {
		llvm::BasicBlock* cur_block = Builder.GetInsertBlock();
		llvm::Function* parent = Builder.GetInsertBlock()->getParent();
        llvm::BasicBlock* if_blk = llvm::BasicBlock::Create(TheContext, "if", parent);
        llvm::BasicBlock* true_blk = llvm::BasicBlock::Create(TheContext, "ifTrue", parent);
        llvm::BasicBlock* else_blk = NULL; 
        llvm::BasicBlock* end_blk = NULL;
        llvm::Value* condition = NULL;
        Builder.CreateBr(if_blk);
        Builder.SetInsertPoint(if_blk);
        condition = condition_->codegen();
        if(else_block_ != NULL){
            else_blk = llvm::BasicBlock::Create(TheContext, "ifElse", parent);
            end_blk = llvm::BasicBlock::Create(TheContext, "ifEnd", parent);
            Builder.CreateCondBr(condition, true_blk, else_blk);
            Builder.SetInsertPoint(else_blk);
            else_block_->codegen();
            Builder.CreateBr(end_blk);
        }
        else{
            end_blk = llvm::BasicBlock::Create(TheContext, "ifEnd", parent);
            Builder.CreateCondBr(condition, true_blk, end_blk);
        }
        Builder.SetInsertPoint(true_blk);
        block_->codegen();
        Builder.CreateBr(end_blk);
        Builder.SetInsertPoint(end_blk);
        return NULL;
	}
};

/*** While_AST
*/
class While_AST : public Stmt_AST
{
	Expr_AST *condition_;
	Block_AST *block_;

	public:
	While_AST(Expr_AST *condition, Block_AST *blk) 
		:Stmt_AST(), condition_(condition), block_(blk) { }

	~While_AST() {
		if( condition_ != NULL) {
			delete condition_;
		}
		if( block_ != NULL) {
			delete block_;
		}
	}

	string str() { 
		return string("WhileStmt(") + getString(condition_) + "," + getString(block_) + ")";
	}

	llvm::Value *codegen() {
        TheTable.scope_in();
		llvm::BasicBlock *cur_block = Builder.GetInsertBlock();
		llvm::Function *function = Builder.GetInsertBlock()->getParent();
		llvm::BasicBlock* while_blk = llvm::BasicBlock::Create(TheContext, "while", function);
		llvm::BasicBlock* do_blk = llvm::BasicBlock::Create(TheContext, "do", function);
		llvm::BasicBlock* end_while = llvm::BasicBlock::Create(TheContext, "endWhile", function);
        TheTable.insert("loop", while_blk);
        TheTable.insert("endloop", end_while);
        Builder.CreateBr(while_blk);
        Builder.SetInsertPoint(while_blk);
        llvm::Value* condition = condition_->codegen();
        Builder.CreateCondBr(condition, do_blk, end_while);
        Builder.SetInsertPoint(do_blk);
        block_->codegen();
        Builder.CreateBr(while_blk);
        Builder.SetInsertPoint(end_while);
        TheTable.scope_out();
        return NULL;
	}
};

/*** For_AST
*/
class For_AST : public Stmt_AST
{
	Node_List_AST *assignment_list_;
	Expr_AST *condition_;
	Node_List_AST *loop_assign_list_;
	Block_AST *block_;

	public:
	For_AST(Node_List_AST *assigns, Expr_AST *condition, Node_List_AST *loop_assigns, Block_AST *block) 
		:Stmt_AST(), assignment_list_(assigns), condition_(condition), loop_assign_list_(loop_assigns), block_(block) { }

	~For_AST() {
		if( assignment_list_ != NULL) {
			delete assignment_list_;
		}
		if( condition_ != NULL) {
			delete condition_;
		}
		if( loop_assign_list_ != NULL) {
			delete loop_assign_list_;
		}
	}

	string str() { 
		return string("ForStmt(") + getString(assignment_list_) + "," + getString(condition_) + "," + getString(loop_assign_list_) + "," + getString(block_) +")";
	}

	llvm::Value *codegen() {
        TheTable.scope_in();
        assignment_list_->codegen();
				llvm::BasicBlock *cur_block = Builder.GetInsertBlock();
				llvm::Function *function = Builder.GetInsertBlock()->getParent();
				llvm::BasicBlock* for_blk = llvm::BasicBlock::Create(TheContext, "for", function);
				llvm::BasicBlock* do_blk = llvm::BasicBlock::Create(TheContext, "do", function);
				llvm::BasicBlock* increment_blk = llvm::BasicBlock::Create(TheContext, "increment", function);
				llvm::BasicBlock* end_for = llvm::BasicBlock::Create(TheContext, "endfor", function);
				TheTable.insert("loop", increment_blk);
				TheTable.insert("endloop", end_for);
				Builder.CreateBr(for_blk);
				Builder.SetInsertPoint(for_blk);
				llvm::Value* condition = condition_->codegen();
				Builder.CreateCondBr(condition, do_blk, end_for);
				Builder.SetInsertPoint(do_blk);
				block_->codegen();
				Builder.CreateBr(increment_blk);
				Builder.SetInsertPoint(increment_blk);
				loop_assign_list_->codegen();
				Builder.CreateBr(for_blk);
				Builder.SetInsertPoint(end_for);
				TheTable.scope_out();
				return NULL;
	}
};

/*** Return_AST
*/
class Return_AST : public Stmt_AST
{
	Expr_AST *value_;

	public:
	Return_AST() 
		:Stmt_AST(), value_(NULL) { }

	Return_AST(Expr_AST *value) 
		:value_(value) { }

	~Return_AST() {
		if( value_ != NULL) {
			delete value_;
		}
	}

	string str() { 
		if(value_ != NULL){
			return string("ReturnStmt(") + getString(value_) + ")";
		}
		else { 
			return string("ReturnStmt(None)");
		}
	}

	llvm::Value *codegen() {
		llvm::Value* value = nullptr;
		if(value_ != NULL){
			value = value_->codegen();
			llvm::Type* type = value->getType();
			llvm::BasicBlock *cur_block = Builder.GetInsertBlock();
			llvm::Function *function = Builder.GetInsertBlock()->getParent();
			llvm::Type* return_type = function->getReturnType();
		}
		return Builder.CreateRet(value);
	}
};

/*** Break_AST
*/
class Break_AST : public Stmt_AST
{
	public:
		Break_AST()
			:Stmt_AST() { };

		~Break_AST() { }

		string str() { 
			return string("BreakStmt");
		}

		llvm::Value *codegen() {
            llvm::Value* value = TheTable.get("endloop");
            llvm::BasicBlock* end_loop = llvm::dyn_cast<llvm::BasicBlock>(value);
            return Builder.CreateBr(end_loop);
		}
};

/*** Continue_AST
*/
class Continue_AST : public Stmt_AST
{
	public:
		Continue_AST()
			:Stmt_AST() { };

		~Continue_AST() { }

		string str() { 
			return string("ContinueStmt");
		}

        llvm::Value *codegen() {
            llvm::Value* value = TheTable.get("loop");
            llvm::BasicBlock* loop = llvm::dyn_cast<llvm::BasicBlock>(value);
            return Builder.CreateBr(loop);
        }
};

/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
 * Package
 */

class Package_AST : public Decaf_AST {
	Node_List_AST *field_list_;
	Node_List_AST *method_list_;

	public:
	Package_AST(string name, Node_List_AST *fieldlist, Node_List_AST *methodlist) 
		:Decaf_AST(name), field_list_(fieldlist), method_list_(methodlist) {}

	~Package_AST() { 
		if (field_list_ != NULL) { delete field_list_; }
		if (method_list_ != NULL) { delete method_list_; }
	}

	string str() { 
		return string("Package") + "(" + name_ + "," + getString(field_list_) + "," + getString(method_list_) + ")";
	}

	llvm::Value *codegen() { 
		TheTable.scope_in();
		llvm::Value *val = NULL;
		TheModule->setModuleIdentifier(llvm::StringRef(name_)); 
		if (NULL != field_list_) {
			val = field_list_->codegen();
		}
		if (NULL != method_list_) {
			val = method_list_->codegen();
		} 
		while(!block_stack.empty()){
			Block_Stack_Element element = block_stack.front();
			Method_Block_AST* block_ast = element.first;
			llvm::BasicBlock* block_llvm = element.second;
			Builder.SetInsertPoint(block_llvm);
			block_ast->codegen();
			block_stack.pop();
		}
		// Q: should we enter the class name into the symbol table?
		TheTable.scope_out();
		return val; 
	}
};

/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
 * Program
 */

/// Program_AST - the decaf program
class Program_AST : public Decaf_AST {
	Node_List_AST *extern_list_;
	Package_AST *package_def_;

	public:
	Program_AST(Node_List_AST *externs, Package_AST *c) 
		:Decaf_AST(), extern_list_(externs), package_def_(c) {}

	~Program_AST() { 
		if (extern_list_ != NULL) { delete extern_list_; } 
		if (package_def_ != NULL) { delete package_def_; }
	}

	string str() {
		return string("Program") + "(" + getString(extern_list_) + "," + getString(package_def_) + ")";
	}

	llvm::Value *codegen() { 
		TheTable.scope_in();
		llvm::Value *val = NULL;
		if (NULL != extern_list_) {
			val = extern_list_->codegen();
		}
		if (NULL != package_def_) {
			val = package_def_->codegen();
		} else {
			throw runtime_error("no package definition in decaf program");
		}
		return val; 
	}
};
