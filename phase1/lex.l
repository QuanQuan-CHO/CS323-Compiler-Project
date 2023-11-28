%{ 
    using namespace std;

    #include "syntax.tab.h"

    #define LEXICAL_ERROR lexical_error(yytext,yylineno)
    
    /* Rewrite the internal macro in Flex to update the location */
    int yycolno = 1;
    #define YY_USER_ACTION \
    yylloc.first_line = yylineno; \
    yylloc.first_column = yycolno; \
    yylloc.last_line = yylineno; \
    yylloc.last_column = yycolno + yyleng; \
    yycolno += yyleng;

    extern bool has_error; //Has lexical or syntax error
    void lexical_error(char* unknown_lexeme, int lineno){
        has_error=true;
        printf("Error type A at Line %d: unknown lexeme %s\n", lineno, unknown_lexeme);
    }
%}

%option yylineno
%x macro

valid_decimal_int 0|[1-9][0-9]*
id [_a-zA-Z][_0-9a-zA-Z]*

%%
"//".* /*ignore single-line comment*/
"/*"(\*[^/]|[^*])*"*/" /*ignore multi-line comment*/
\"(\\\"|[^\"])*\" {asprintf(&yylval,"STRING: %s\n",yytext); return STRING;}
"#define" {yylval=strdup("DEFINE\n"); BEGIN(macro); return DEFINE;}
"#include" {yylval=strdup("INCLUDE\n"); BEGIN(macro); return INCLUDE;}
"#ifdef" {yylval=strdup("IFDEF\n"); BEGIN(macro); return IFDEF;}
"#else" {yylval=strdup("MACROELSE\n"); return MACROELSE;}
"#endif" {yylval=strdup("ENDIF\n"); return ENDIF;}
<macro>{
    "," {yylval=strdup("COMMA\n"); return COMMA;}
    "<" {yylval=strdup("LT\n"); return LT;}
    ">" {yylval=strdup("GT\n"); return GT;}
    \"  {yylval=strdup("DQUOT\n"); return DQUOT;}
    \n  {BEGIN(INITIAL);}
    [ \t]+ /*ignore word splits*/
    [^," "<>"\n]+ {asprintf(&yylval,"MACRO: %s\n",yytext); return MACRO;}
}
int|float|char|string {asprintf(&yylval,"TYPE: %s\n",yytext); return TYPE;}
for {yylval=strdup("FOR\n"); return FOR;}
struct {yylval=strdup("STRUCT\n"); return STRUCT;}
if {yylval=strdup("IF\n"); return IF;}
else {yylval=strdup("ELSE\n"); return ELSE;}
while {yylval=strdup("WHILE\n"); return WHILE;}
return {yylval=strdup("RETURN\n"); return RETURN;}
    /* Because CHAR is 2 Byte, only 1 or 2 hex char is allowed */
'([^']|\\[xX](0|[1-9a-fA-F][0-9a-fA-F]?))' {asprintf(&yylval,"CHAR: %s\n",yytext); return CHAR;}
'[^']*' {LEXICAL_ERROR; return CHAR;} /*Invalid CHAR: not matched by the above valid CHAR regex will fail to this regex*/
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
"&" {LEXICAL_ERROR; return AND;} //treat & as AND to prevent the syntax error later
"||" {yylval=strdup("OR\n"); return OR;}
"|" {LEXICAL_ERROR; return OR;} //treat | as OR to prevent the syntax error later
"(" {yylval=strdup("LP\n"); return LP;}
")" {yylval=strdup("RP\n"); return RP;}
"[" {yylval=strdup("LB\n"); return LB;}
"]" {yylval=strdup("RB\n"); return RB;}
"{" {yylval=strdup("LC\n"); return LC;}
"}" {yylval=strdup("RC\n"); return RC;}
({valid_decimal_int})\.[0-9]+ {asprintf(&yylval,"FLOAT: %s\n",yytext); return FLOAT;}
({valid_decimal_int})\.[\.0-9]+ {LEXICAL_ERROR; return FLOAT;} /*Invalid float(with multiple dot): not matched by the above valid FLOAT regex will fail to this regex*/
{valid_decimal_int} {asprintf(&yylval,"INT: %s\n",yytext); return INT;/* not include minus number */}
0[xX](0|[1-9a-fA-F][0-9a-fA-F]*) {asprintf(&yylval,"INT: %lu\n",strtol(yytext,&yytext,16)); return INT;} /* valid_hex_int should be converted to decimal form */
0[0-9]+|0[xX]0[0-9a-fA-F]+ {LEXICAL_ERROR; return INT;} /* invalid decimal and hex INT: starting with 0 */
[0-9]+{id} {LEXICAL_ERROR; return ID;}
{id} {asprintf(&yylval,"ID: %s\n",yytext); return ID;}
"." {yylval=strdup("DOT\n"); return DOT;}
\n {yycolno=1;}
[ \r\t]+ /*ignore word splits*/
. {yymore(); LEXICAL_ERROR;}

%%
