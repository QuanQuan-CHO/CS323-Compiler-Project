%{ 
    using namespace std;
    
    #define EXIT_OK 0
    #define EXIT_FAIL 1
    #define YYSTYPE char* /* Define the type of `yylval` */
    /* Rewrite the internal macro in Flex to update the location */
    int yycolno = 1;
    #define YY_USER_ACTION \
    yylloc.first_line = yylineno; \
    yylloc.first_column = yycolno; \
    yylloc.last_line = yylineno; \
    yylloc.last_column = yycolno + yyleng; \
    yycolno += yyleng;

    extern bool has_error; //Has lexical or syntax error

    #include "syntax.tab.h"
    #include <string.h>
    #include <regex>
    void lexical_error(char* unknown_lexeme, int lineno){
        has_error=true;
        printf("Error type A at Line %d: unknown lexeme %s\n", lineno, unknown_lexeme);
    }
%}

%option yylineno
%option debug

valid_decimal_int 0|[1-9][0-9]*
valid_hex_int [xX](0|[1-9a-f][0-9a-f]*)
id [_a-zA-Z][_0-9a-zA-Z]*
%x macro
%%
    /*TODO: handle comment*/
    /*TODO: handle string*/

"//".* {}
"/*"((("*"[^/])?)|[^*])*"*/"  {}
"#define" {yylval=strdup("DEFINE\n"); BEGIN(macro); return DEFINE;}
"#include" {yylval=strdup("INCLUDE\n"); BEGIN(macro); return INCLUDE;}
"#ifdef" {yylval=strdup("IFDEF\n"); BEGIN(macro); return IFDEF;}
"#else" {yylval=strdup("MACROELSE\n"); BEGIN(macro); return MACROELSE;}
"#endif" {yylval=strdup("ENDIF\n"); BEGIN(macro); return ENDIF;}
<macro>{
    "," {yylval=strdup("COMMA\n");return COMMA;}
    "<" {return LT;}
    ">" {return GT;}
    \"  {return DQUOT;}
    \n  {BEGIN(INITIAL);}
    [ \t]+ /*ignore word splits*/{}
    [^," "<>"\n]+ {asprintf(&yylval,"%s\n",yytext);return MACRO;}
}
int|float|char {asprintf(&yylval,"TYPE: %s\n",yytext); return TYPE;}
for {yylval=strdup("FOR\n"); return FOR;}
struct {yylval=strdup("STRUCT\n"); return STRUCT;}
if {yylval=strdup("IF\n"); return IF;}
else {yylval=strdup("ELSE\n"); return ELSE;}
while {yylval=strdup("WHILE\n"); return WHILE;}
return {yylval=strdup("RETURN\n"); return RETURN;}
\\x[^0-9a-fA-F]* {
    printf("Error type A at Line %d: unknown lexeme %s\n", yylineno, yytext);
}
'([^']*)'|\\{valid_hex_int} {asprintf(&yylval,"CHAR: %s\n",yytext); return CHAR;}
";" {yylval=strdup("SEMI\n"); return SEMI;}
"," {yylval=strdup("COMMA\n"); return COMMA;}
"==" {yylval=strdup("EQ\n"); return EQ;}
"<=" {yylval=strdup("LE\n"); return LE;}
">=" {yylval=strdup("GE\n"); return GE;}
"!=" {yylval=strdup("NE\n"); return NE;}
"=" {yylval=strdup("ASSIGN\n"); return ASSIGN;}
"!" {yylval=strdup("NOT\n"); return NOT;}
"<" {yylval=strdup("LT\n"); return LT;}
">" {yylval=strdup("GT\n"); return GT;}
"+" {yylval=strdup("PLUS\n"); return PLUS;}
"-" {yylval=strdup("MINUS\n"); return MINUS;}
"*" {yylval=strdup("MUL\n"); return MUL;}
"/" {yylval=strdup("DIV\n"); return DIV;}
"&&" {yylval=strdup("AND\n"); return AND;}
"&" {lexical_error(yytext,yylineno); return AND;} //treat it as AND to prevent the syntax error later
"||" {yylval=strdup("OR\n"); return OR;}
"|" {lexical_error(yytext,yylineno); return OR;} //treat it as OR to prevent the syntax error later
"(" {yylval=strdup("LP\n"); return LP;}
")" {yylval=strdup("RP\n"); return RP;}
"[" {yylval=strdup("LB\n"); return LB;}
"]" {yylval=strdup("RB\n"); return RB;}
"{" {yylval=strdup("LC\n"); return LC;}
"}" {yylval=strdup("RC\n"); return RC;}
[0-9]+{id} {lexical_error(yytext, yylineno); return ID;}
{id} {asprintf(&yylval,"ID: %s\n",yytext); return ID;}
({valid_decimal_int})\.[0-9]+ {asprintf(&yylval,"FLOAT: %s\n",yytext); return FLOAT;}
{valid_decimal_int}|0{valid_hex_int} {asprintf(&yylval,"INT: %s\n",yytext); return INT;/* not include minus number */}
\\x(0|[1-9a-f][0-9a-f]*)[^0-9a-fA-F] {
    printf("Error type A at Line %d: unknown lexeme %s\n", yylineno, strdup(yytext));
}
"." {yylval=strdup("DOT\n"); return DOT;}
\n {yycolno=1;}
[ \r\t]+ /*ignore word splits*/
. {lexical_error(yytext, yylineno);}



%%