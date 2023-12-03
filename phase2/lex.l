%{ 
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
    /*TODO: handle string*/
"//".* /*ignore single-line comment*/
"/*"(\*[^/]|[^*])*"*/" /*ignore multi-line comment*/
\"(\\\"|[^\"])*\" { return STRING;}
"#define" { BEGIN(macro); return DEFINE;}
"#include" { BEGIN(macro); return INCLUDE;}
"#ifdef" { BEGIN(macro); return IFDEF;}
"#else" { return MACROELSE;}
"#endif" {return ENDIF;}
<macro>{
    "," { return COMMA;}
    "<" { return LT;}
    ">" { return GT;}
    \"  { return DQUOT;}
    \n  {BEGIN(INITIAL);}
    [ \t]+ /*ignore word splits*/
    [^," "<>"\n]+ { return MACRO;}
}
int {yylval.rec_ptr= new rec(intvar,yytext);return TYPE;}
float {yylval.rec_ptr= new rec(floatvar,yytext); return TYPE;}
char {yylval.rec_ptr= new rec(charvar,yytext); return TYPE;}
for { return FOR;}
struct {yylval.rec_ptr= new rec(structvar,yytext); return STRUCT;}
if { return IF;}
else { return ELSE;}
while { return WHILE;}
return { return RETURN;}
    /* Because CHAR is 2 Byte, only 1 or 2 hex char is allowed */
'([^']|\\[xX](0|[1-9a-fA-F][0-9a-fA-F]?))' {yylval.rec_ptr= new rec(charvar,yytext); return CHAR;}

";" {return SEMI;}
"," {return COMMA;}
"==" {yylval.rec_ptr= new rec(biop,yytext); return EQ;}
"<=" {yylval.rec_ptr= new rec(biop,yytext); return LE;}
">=" {yylval.rec_ptr= new rec(biop,yytext); return GE;}
"!=" {yylval.rec_ptr= new rec(biop,yytext); return NE;}
"=" {yylval.rec_ptr= new rec(biop,yytext); return ASSIGN;}
"!" {yylval.rec_ptr= new rec(siop,yytext); return NOT;}
"<" {yylval.rec_ptr= new rec(biop,yytext); return LT;}
">" {yylval.rec_ptr= new rec(biop,yytext); return GT;}
"+" {yylval.rec_ptr= new rec(biop,yytext); return PLUS;}
"-" {yylval.rec_ptr= new rec(biop,yytext); return MINUS;}
"*" {yylval.rec_ptr= new rec(biop,yytext); return MUL;}
"/" {yylval.rec_ptr= new rec(biop,yytext); return DIV;}
"&&" {yylval.rec_ptr= new rec(biop,yytext); return AND;}
"&" {LEXICAL_ERROR; return AND;} //treat & as AND to prevent the syntax error later
"||" {yylval.rec_ptr= new rec(biop,yytext); return OR;}
"|" {LEXICAL_ERROR; return OR;} //treat | as OR to prevent the syntax error later
"(" { return LP;}
")" { return RP;}
"[" { return LB;}
"]" { return RB;}
"{" { return LC;}
"}" { return RC;}
({valid_decimal_int})\.[0-9]+ {yylval.rec_ptr= new rec(floatvar,yytext); return FLOAT;}

{valid_decimal_int} { /* not include minus number */
yylval.rec_ptr= new rec(intvar,yytext);
    long integer = strtol(yytext,&yytext,10);
    if(integer>=INT32_MIN && integer<=INT32_MAX){
        
    }
    return INT;
}
0[xX](0|[1-9a-fA-F][0-9a-fA-F]*) {yylval.rec_ptr= new rec(intvar,yytext); return INT;} /* valid_hex_int should be converted to decimal form */
0[0-9]+|0[xX]0[0-9a-fA-F]+ {LEXICAL_ERROR; return INT;} /* invalid decimal and hex INT: starting with 0 */
[0-9]+{id} {LEXICAL_ERROR; return ID;}
{id} {yylval.rec_ptr= new rec(var,yytext); return ID;}
"." {yylval.rec_ptr=new rec(var,yytext); return DOT;}
\n {yycolno=1;}
[ \r\t]+ /*ignore word splits*/
. {yymore(); }

%%
