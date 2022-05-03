%{

#include <iostream>
#include <cstdlib>
using namespace std;

#define T_AND            1 
#define T_ASSIGN         2 
#define T_BOOLTYPE       3 
#define T_BREAK          4 
#define T_CHARCONSTANT   5 
#define T_COMMA          6 
#define T_COMMENT        7 
#define T_CONTINUE       8 
#define T_DIV            9 
#define T_DOT            10 
#define T_ELSE           11 
#define T_EQ             12 
#define T_EXTERN         13 
#define T_FALSE          14 
#define T_FOR            15 
#define T_FUNC           16 
#define T_GEQ            17 
#define T_GT             18 
#define T_ID             19 
#define T_IF             20 
#define T_INTCONSTANT    21 
#define T_INTTYPE        22 
#define T_LCB            23 
#define T_LEFTSHIFT      24 
#define T_LEQ            25 
#define T_LPAREN         26 
#define T_LSB            27 
#define T_LT             28 
#define T_MINUS          29 
#define T_MOD            30 
#define T_MULT           31 
#define T_NEQ            32 
#define T_NOT            33 
#define T_NULL           34 
#define T_OR             35 
#define T_PACKAGE        36 
#define T_PLUS           37 
#define T_RCB            38 
#define T_RETURN         39 
#define T_RIGHTSHIFT     40 
#define T_RPAREN         41 
#define T_RSB            42 
#define T_SEMICOLON      43 
#define T_STRINGCONSTANT 44 
#define T_STRINGTYPE     45 
#define T_TRUE           46 
#define T_VAR            47 
#define T_VOID           48 
#define T_WHILE          49 
#define T_WHITESPACE     50

// The compiler yells about yylex being undefined without this on my system.
// May be removed for final version.
extern "C" int yylex();

/**
 * Prints tokens in proper format.
 * @param type The token type.
 * @param lexem The token contents.
 * @return void
 */
void print_token(string type, string lexeme)
{
	string newline = "\n";
	string::iterator iter = lexeme.begin();
	string::iterator end = lexeme.end();
	int pos = lexeme.find(newline);

	cout << type << " ";
	while(iter != end){
		if(*iter == '\n'){
			cout << "\\n";
		}
		else{
			cout << *iter;
		}
		iter++;
	}
	cout << endl;

	return;
}

%}

	/* Keywords */
booltype       bool
break          break
continue       continue
else           else
extern         extern
false          false
for            for
func           func
if             if
inttype        int
null           null
package        package
return         return
stringtype     string
true           true
var						 var
void           void
while          while

	/* Operators */
and            \&{2}
assign         \=
comma          \,
div            \/
dot            \.
eq             \={2}
geq            >=
gt             >
lcb						 \{
leftshift      <<
leq            <=
lparen				 \(
lsb            \[
lt             <
minus          -
mod            %
mult           \*
neq            !=
not            !
or             \|{2}
plus           \+
rcb						 \}
rightshift     >>
rparen				 \)
rsb            \]
semicolon      ;

	/* Literals */
letter				 [a-zA-Z\_]
digit					 [0-9]
hex_digit			 [0-9a-fA-F]
whitespace		 [\t\r\a\v\b\n ]
char					 [^"'\\\n\r\v\f\a\b]
escaped_char	 [nrtvfab\\'"]


 /* Comments */
comment	 .

%%
  /*
    Pattern definitions for all tokens 
  */

	/* Keywords */
{booltype}		{ return T_BOOLTYPE; }
{break}				{ return T_BREAK; }
{continue}		{ return T_CONTINUE; }
{else}				{ return T_ELSE; }
{extern}			{ return T_EXTERN; }
{false}				{ return T_FALSE; }
{for}					{ return T_FOR; }
{func}				{ return T_FUNC; }
{if}					{ return T_IF; }
{inttype}			{ return T_INTTYPE; }
{null}				{ return T_NULL; }
{package}			{ return T_PACKAGE; }
{return}			{ return T_RETURN; }
{true}				{ return T_TRUE; }
{var}					{ return T_VAR; }
{void}				{ return T_VOID; }
{stringtype}	{ return T_STRINGTYPE; }

	/* Operators */
{and}					{ return T_AND; }
{assign}			{ return T_ASSIGN; }
{comma}				{ return T_COMMA; }
{div}					{ return T_DIV; }
{dot}					{ return T_DOT; }
{eq}					{ return T_EQ; }
{geq}					{ return T_GEQ; }
{gt}					{ return T_GT; }
{lcb}					{ return T_LCB; }
{leftshift}		{ return T_LEFTSHIFT; }
{leq}					{ return T_LEQ; }
{lparen}			{ return T_LPAREN; }
{lsb}					{ return T_LSB; }
{lt}					{ return T_LT; }
{minus}				{ return T_MINUS; }
{mod}					{ return T_MOD; }
{mult}				{ return T_MULT; }
{neq}					{ return T_NEQ; }
{not}					{ return T_NOT; }
{or}					{ return T_OR; }
{plus}				{ return T_PLUS; }
{rcb}					{ return T_RCB; }
{rightshift}	{ return T_RIGHTSHIFT; }
{rparen}			{ return T_RPAREN; }
{rsb}					{ return T_RSB; }
{semicolon}		{ return T_SEMICOLON; }
{whitespace}+	{ return T_WHITESPACE; }

	/* Literals */
\"({char}|\\{escaped_char}|\')*\"				{ return T_STRINGCONSTANT; }
\'({char}|\\{escaped_char}|\")\'				{ return T_CHARCONSTANT; }

{digit}+ { return T_INTCONSTANT; }
0[xX]{hex_digit}+						{ return T_INTCONSTANT; }
{letter}({letter}|{digit})*	{ return T_ID; }

 /* Comment */
"//"{comment}*\n?        { return T_COMMENT; }

	/* Error */
.	{ cerr << "Error: unexpected character in input" << endl; return -1; }

%%

int main () {
	int token;
	string lexeme;
	string type;

	while ((token = yylex())) {
		if (token > 0) {
			lexeme.assign(yytext);
			switch(token)
			{
				case T_AND:
					type = "T_AND";
					break;
				case T_ASSIGN:
					type = "T_ASSIGN";
					break;
				case T_BOOLTYPE:
					type = "T_BOOLTYPE";
					break;
				case T_BREAK:
					type = "T_BREAK";
					break;
				case T_CHARCONSTANT:
					type = "T_CHARCONSTANT";
					break;
				case T_COMMA:
					type = "T_COMMA";
					break;
				case T_COMMENT:
					type = "T_COMMENT";
					break;
				case T_CONTINUE:
					type = "T_CONTINUE";
					break;
				case T_DIV:
					type = "T_DIV";
					break;
				case T_DOT:
					type = "T_DOT";
					break;
				case T_ELSE:
					type = "T_ELSE";
					break;
				case T_EQ:
					type = "T_EQ";
					break;
				case T_EXTERN:
					type = "T_EXTERN";
					break;
				case T_FALSE:
					type = "T_FALSE";
					break;
				case T_FOR:
					type = "T_FOR";
					break;
				case T_FUNC:
					type = "T_FUNC";
					break;
				case T_GEQ:
					type = "T_GEQ";
					break;
				case T_GT:
					type = "T_GT";
					break;
				case T_ID:
					type = "T_ID";
					break;
				case T_IF:
					type = "T_IF";
					break;
				case T_INTCONSTANT:
					type = "T_INTCONSTANT";
					break;
				case T_INTTYPE:
					type = "T_INTTYPE";
					break;
				case T_LCB:
					type = "T_LCB";
					break;
				case T_LEFTSHIFT:
					type = "T_LEFTSHIFT";
					break;
				case T_LEQ:
					type = "T_LEQ";
					break;
				case T_LPAREN:
					type = "T_LPAREN";
					break;
				case T_LSB:
					type = "T_LSB";
					break;
				case T_LT:
					type = "T_LT";
					break;
				case T_MINUS:
					type = "T_MINUS";
					break;
				case T_MOD:
					type = "T_MOD";
					break;
				case T_MULT:
					type = "T_MULT";
					break;
				case T_NEQ:
					type = "T_NEQ";
					break;
				case T_NOT:
					type = "T_NOT";
					break;
				case T_NULL:
					type = "T_NULL";
					break;
				case T_OR:
					type = "T_OR";
					break;
				case T_PACKAGE:
					type = "T_PACKAGE";
					break;
				case T_PLUS:
					type = "T_PLUS";
					break;
				case T_RCB:
					type = "T_RCB";
					break;
				case T_RETURN:
					type = "T_RETURN";
					break;
				case T_RIGHTSHIFT:
					type = "T_RIGHTSHIFT";
					break;
				case T_RPAREN:
					type = "T_RPAREN";
					break;
				case T_RSB:
					type = "T_RSB";
					break;
				case T_SEMICOLON:
					type = "T_SEMICOLON";
					break;
				case T_STRINGCONSTANT:
					type = "T_STRINGCONSTANT";
					break;
				case T_STRINGTYPE:
					type = "T_STRINGTYPE";
					break;
				case T_TRUE:
					type = "T_TRUE";
					break;
				case T_VAR:
					type = "T_VAR";
					break;
				case T_VOID:
					type = "T_VOID";
					break;
				case T_WHILE:
					type = "T_WHILE";
					break;
				case T_WHITESPACE:
					type = "T_WHITESPACE";
					break;
				default:
					exit(EXIT_FAILURE);
			}
			print_token(type, lexeme);
		} 
		else if (token < 0) {
			exit(EXIT_FAILURE);
		}
	}
	exit(EXIT_SUCCESS);
}

