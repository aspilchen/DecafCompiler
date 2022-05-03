
#include "decafast-defs.h"
#include <list>
#include <ostream>
#include <iostream>
#include <sstream>

#ifndef YYTOKENTYPE
//#include "decafast.tab.h"
#endif

using namespace std;

/*** Decaf_AST
 * Base class for all abstract syntax tree nodes.
 */
class Decaf_AST {
public:
  virtual ~Decaf_AST() {}
  virtual string str() { return string(""); }
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

/** Node_List_AST
 * List of decaf statements.
 */
class Node_List_AST : public Decaf_AST {
	list<Decaf_AST *> nodes_;

public:
	Node_List_AST() {}
	~Node_List_AST() {
		for (list<Decaf_AST *>::iterator i = nodes_.begin(); i != nodes_.end(); i++) { 
			delete *i;
		}
	}

	int size() {
		return nodes_.size();
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
	
	string str() { return commaList<class Decaf_AST *>(nodes_); }
};


/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
 * Expressions
 */

/*** Superclass for all expressions.
 */
class Expr_AST : public Decaf_AST
{ };

/** Number_Expr_AST
 * Number expression.
 */
class Number_AST : public Expr_AST
{
	string value_;

public:
	Number_AST(string value) 
		: value_(value) {}

	~Number_AST() { }

	string str() { 
		return string("NumberExpr(")  + value_ +  ")";
	}
};

/** Bool_AST
 * Boolean expression.
 */
class Bool_AST : public Expr_AST
{
	string value_;

public:
	Bool_AST(string value) 
		: value_(value) {}

	~Bool_AST() { }

	string str() { 
		return string("BoolExpr(")  + value_ +  ")";
	}
};

/** Binary_AST
 * Binary expression.
 */
class Binary_AST : public Expr_AST
{
	string operator_;
	Expr_AST *left_val_;
	Expr_AST *right_val_;

public:
	Binary_AST(string op, Expr_AST *lval, Expr_AST *rval) 
		: operator_(op), left_val_(lval), right_val_(rval) {}

	~Binary_AST() {
		delete left_val_;
		delete right_val_;
	}

	string str() { 
		return string("BinaryExpr(")  + operator_ + "," + getString(left_val_) + "," + getString(right_val_) + ")";
	}
};

/** Unary_AST
 * Unary expression.
 */
class Unary_AST : public Expr_AST
{
	string operator_;
	Expr_AST *value_;

public:
	Unary_AST(string op, Expr_AST *val) 
		: operator_(op), value_(val) {}

	~Unary_AST() {
		delete value_;
	}

	string str() { 
		return string("UnaryExpr(")  + operator_ + "," + getString(value_) + ")";
	}
};

/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
 * Constants
 */

class String_Const_AST : public Expr_AST
{
	string value_;

public:
	String_Const_AST(string value) 
		: value_(value) {}

	~String_Const_AST() { }

	string str() { return string("StringConstant(") + value_ + ")";
	}
};

/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
 * Package
 */

class PackageAST : public Decaf_AST 
{
	string Name;
	Node_List_AST *FieldDeclList;
	Node_List_AST *MethodDeclList;
public:
	PackageAST(string name, Node_List_AST *fieldlist, Node_List_AST *methodlist) 
		: Name(name), FieldDeclList(fieldlist), MethodDeclList(methodlist) {}
	~PackageAST() { 
		if (FieldDeclList != NULL) { delete FieldDeclList; }
		if (MethodDeclList != NULL) { delete MethodDeclList; }
	}
	string str() { 
		return string("Package(") + Name + "," + getString(FieldDeclList) + "," + getString(MethodDeclList) + ")";
	}
};

/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
 * Program
 */

/// ProgramAST - the decaf program
class ProgramAST : public Decaf_AST {
	Node_List_AST *ExternList;
	PackageAST *PackageDef;
public:
	ProgramAST(Node_List_AST *externs, PackageAST *c) : ExternList(externs), PackageDef(c) {}
	~ProgramAST() { 
		if (ExternList != NULL) { delete ExternList; } 
		if (PackageDef != NULL) { delete PackageDef; }
	}
	string str() { return string("Program") + "(" + getString(ExternList) + "," + getString(PackageDef) + ")"; }
};


/*** Method_Block_AST
 */
class Method_Block_AST : public Decaf_AST 
{
	Node_List_AST *var_list_;
	Node_List_AST *statement_list_;
public:
	Method_Block_AST(Node_List_AST *var_list, Node_List_AST *statement_list) 
		: var_list_(var_list), statement_list_(statement_list) {}
	~Method_Block_AST() { 
		if (var_list_ != NULL) { delete var_list_; }
		if (statement_list_ != NULL) { delete statement_list_; }
	}
	string str() { 
		return string("MethodBlock(") + getString(var_list_) + "," + getString(statement_list_) + ")";
	}
};

/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
 * Variables
 */

/*** Var_Def_AST
 */
class Var_Def_AST : public Decaf_AST
{
	string name_;
	string type_;

public:
	Var_Def_AST(string type) 
		: name_(""), type_(type) {}

	Var_Def_AST(string name, string type) 
		: name_(name), type_(type) {}

	~Var_Def_AST() { }

	string type() { return type_; };

	string str() { 
		string ret_string = "VarDef(";
		if(name_.length() > 0) {
			ret_string += name_ + ",";
		}
		ret_string += type_ + ")";
		return string(ret_string);
	}
};

/*** Array_AST
 */
class Array_AST : public Decaf_AST
{
	string size_;

public:
	Array_AST(string size) 
		: size_(size) {}

	~Array_AST() { }

	string str() { 
		return string("Array(")  + size_ + ")";
	}
};

/*** Field_Decl_AST
 */
class Field_Decl_AST : public Decaf_AST
{
	string name_;
	string type_;
	string size_;

public:
	Field_Decl_AST(string name, string type) 
		: name_(name), type_(type), size_("") {}

	Field_Decl_AST(string name, string type, string size) 
		: name_(name), type_(type), size_(size) {}

	~Field_Decl_AST() { }

	string name() { return name_; }
	string type() { return type_; }
	string size() { return size_; }

	string str() { 
		return string("FieldDecl(" ) + name_ + "," + type_ + "," + size_ +")";
	}
};

/*** Assign_Global_AST
 */
class Assign_Global_AST : public Decaf_AST
{
	string name_;
	string type_;
	Expr_AST *value_;

public:
	Assign_Global_AST(string name, string type, Expr_AST *value) 
		: name_(name), type_(type), value_(value) {}

	~Assign_Global_AST() { }

	string str() { 
		return string("AssignGlobalVar(")  + name_ + "," + type_ + "," + getString(value_) + ")";
	}
};


/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
 * Methods
 */

/*** Method_Decl_AST
 */
class Method_Decl_AST : public Decaf_AST
{
	string name_;
	string return_type_;
	Node_List_AST *param_list_;
	Method_Block_AST *block_;

public:
	Method_Decl_AST(string name, string return_type, Node_List_AST *param_list, Method_Block_AST *block) 
		: name_(name), return_type_(return_type), param_list_(param_list), block_(block) { }

	~Method_Decl_AST() { 
		if(param_list_ != NULL) {
			delete param_list_;
		}
	}

	string str() { 
		return string("Method(") + name_ + "," + return_type_ + "," + getString(param_list_) + "," + getString(block_) + ")";
	}
};


/*** Method_Call_AST
 */
class Method_Call_AST : public Expr_AST
{
	string name_;
	Node_List_AST *arg_list_;

public:
	Method_Call_AST(string name, Node_List_AST *arg_list) 
		: name_(name), arg_list_(arg_list) { }

	~Method_Call_AST() { 
		if(arg_list_ != NULL)
		{
			delete arg_list_;
		}
	}

	string str() { 
		return string("MethodCall(") + name_ + "," + getString(arg_list_) + ")";
	}
};

/*** Variable_Expr_AST
 */
class Variable_Expr_AST : public Expr_AST
{
	string name_;

public:
	Variable_Expr_AST(string name) 
		: name_(name) { }

	~Variable_Expr_AST() { }

	string str() { 
		return string("VariableExpr(") + name_ + ")";
	}
};

/** Array_Loc_Expr_AST
 */
class Array_Loc_Expr_AST : public Expr_AST
{
	string name_;
	Expr_AST *index_;

public:
	Array_Loc_Expr_AST(string name, Expr_AST *index) 
		: name_(name), index_(index) { }

	~Array_Loc_Expr_AST() {
		if(index_ != NULL) {
			delete index_;
		}
	}

	string str() { 
		return string("ArrayLocExpr(") + name_ + "," + getString(index_) + ")";
	}
};


/*** Function_Decl_AST
 */
class Function_Decl_AST : public Expr_AST
{
	string name_;
	string type_;
	Node_List_AST *param_list_;

public:
	Function_Decl_AST(string name, string type, Node_List_AST *params) 
		: name_(name), type_(type), param_list_(params) { }

	~Function_Decl_AST() {
		if(param_list_ != NULL) {
			delete param_list_;
		}
	}

	string str() { 
		return string("ExternFunction(") + name_ + "," + type_ + "," + getString(param_list_) + ")";
	}
};

/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
 * Statements
 */


/*** Stmt_AST
 */
class Stmt_AST : public Decaf_AST
{ };

/** Assign_AST
 */
class Assign_AST : public Stmt_AST
{
protected:
	string name_;
	Expr_AST *value_;

public:
	Assign_AST(string name) 
		: name_(name) { }

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
		: Assign_AST(name) { }

	~Assign_Var_AST() { }

	string str() { 
		return string("AssignVar(") + name_ + "," + getString(value_) + ")";
	}
};

/*** Assign_Array_Loc_AST
 */
class Assign_Array_Loc_AST : public Assign_AST
{
	Expr_AST *index_;

public:
	Assign_Array_Loc_AST(string name, Expr_AST *index) 
		: Assign_AST(name), index_(index) { }

	~Assign_Array_Loc_AST() {
		if(index_ != NULL) {
			delete index_;
		}
	}

	string str() { 
		return string("AssignArrayLoc(") + name_ + "," + getString(index_) + "," + getString(value_) + ")";
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
		: var_list_(var_list), statement_list_(statement_list) {}
	~Block_AST() { 
		if (var_list_ != NULL) { delete var_list_; }
		if (statement_list_ != NULL) { delete statement_list_; }
	}
	string str() { 
		return string("Block(") + getString(var_list_) + "," + getString(statement_list_) + ")";
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
		: condition_(condition), block_(blk), else_block_(else_blk) { }

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
};

/*** While_AST
 */
class While_AST : public Stmt_AST
{
	Expr_AST *condition_;
	Block_AST *block_;

public:
	While_AST(Expr_AST *condition, Block_AST *blk) 
		: condition_(condition), block_(blk) { }

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
		: assignment_list_(assigns), condition_(condition), loop_assign_list_(loop_assigns), block_(block) { }

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
};

/*** Return_AST
 */
class Return_AST : public Stmt_AST
{
	Expr_AST *value_;

public:
	Return_AST() 
		: value_(NULL) { }

	Return_AST(Expr_AST *value) 
		: value_(value) { }

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
};

/*** Break_AST
 */
class Break_AST : public Stmt_AST
{

public:
	Break_AST() { };

	~Break_AST() { }

	string str() { 
		return string("BreakStmt");
	}
};

/*** Continue_AST
 */
class Continue_AST : public Stmt_AST
{

public:
	Continue_AST() { };

	~Continue_AST() { }

	string str() { 
		return string("ContinueStmt");
	}
};
