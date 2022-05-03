%{
#include "decafexpr-defs.h"
#include "decafexpr.tab.h"
#include <cstring>
#include <string>
#include <sstream>
#include <iostream>

using namespace std;

int lineno = 1;
int tokenpos = 1;

%}

	/* Literals */
letter				 [a-zA-Z\_]
digit					 [0-9]
hex_digit			 [0-9a-fA-F]
whitespace		 [\t\r\a\v\b\n ]
char					 [^"'\\\n\r\v\f\a\b]
escaped_char	 [nrtvfab\\'"]

%%
  /*
    Pattern definitions for all tokens 
  */

	/* Keywords */
bool				{ return T_BOOLTYPE; }
break				{ return T_BREAK; }
continue		{ return T_CONTINUE; }
else				{ return T_ELSE; }
extern			{ return T_EXTERN; }
false				{ return T_FALSE; }
for					{ return T_FOR; }
func				{ return T_FUNC; }
if					{ return T_IF; }
int			{ return T_INTTYPE; }
null				{ return T_NULL; }
package			{ return T_PACKAGE; }
return			{ return T_RETURN; }
true				{ return T_TRUE; }
var					{ return T_VAR; }
void				{ return T_VOID; }
string	{ return T_STRINGTYPE; }
while		{ return T_WHILE; }

	/* Operators */
"&&"					{ return T_AND; }
"="			{ return T_ASSIGN; }
","				{ return T_COMMA; }
"/"					{ return T_DIV; }
"."					{ return T_DOT; }
"=="					{ return T_EQ; }
">="					{ return T_GEQ; }
">"					{ return T_GT; }
"{"					{ return T_LCB; }
"<<"		{ return T_LEFTSHIFT; }
"<="					{ return T_LEQ; }
"("			{ return T_LPAREN; }
"["					{ return T_LSB; }
"<"					{ return T_LT; }
"-"				{ return T_MINUS; }
"%"					{ return T_MOD; }
"*"				{ return T_MULT; }
"!="					{ return T_NEQ; }
"!"					{ return T_NOT; }
"||"					{ return T_OR; }
"+"				{ return T_PLUS; }
"}"					{ return T_RCB; }
">>"	{ return T_RIGHTSHIFT; }
")"			{ return T_RPAREN; }
"]"					{ return T_RSB; }
";"		{ return T_SEMICOLON; }

	/* Literals */
\"({char}|\\{escaped_char}|\')*\"				{ yylval.sval = new string(yytext); return T_STRINGCONSTANT; }
\'({char}|\\{escaped_char}|\")\'				{ yylval.sval = new string(yytext); return T_CHARCONSTANT; }

{digit}+|(0[xX]{hex_digit}+) { yylval.sval = new string(yytext); return T_INTCONSTANT; }
{letter}({letter}|{digit})*  { yylval.sval = new string(yytext); return T_ID; } /* note that identifier pattern must be after all keywords */
[\t\r\n\a\v\b ]+           { } /* ignore whitespace */

 /* Comment */
"//".*\n?        {  } /* Ignore comments. */

.                          { cerr << "Error: unexpected character '" << yytext << "'in input" << endl; return -1; }

%%

int yyerror(const char *s) {
  cerr << lineno << ": " << s << " at char " << tokenpos << endl;
  return 1;
}

