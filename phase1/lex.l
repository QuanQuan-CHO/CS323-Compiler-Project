%{
    #define EXIT_OK 0
    #define EXIT_FAIL 1
    #define YYSTYPE char *
    #include "string.h"
    #include "syntax.tab.h"

    /* Rewrite the internal macro in Flex to update the location */
    int yycolno = 1;
    #define YY_USER_ACTION \
    yylloc.first_line = yylineno; \
    yylloc.first_column = yycolno; \
    yylloc.last_line = yylineno; \
    yylloc.last_column = yycolno + yyleng; \
    yycolno += yyleng;
%}

%option yylineno


valid_decimal_int 0|[1-9][0-9]*
valid_hex_int [xX](0|[1-9a-f][0-9a-f]*)

%%
    /*TODO: handle comment*/
    /*TODO: handle string*/

"//".* {}
"/*"((("*"[^/])?)|[^*])*"*/"  {}
int|float|char { yylval = strdup(yytext); return TYPE; }
struct { yylval = "STRUCT"; return STRUCT; }
if { yylval = "IF"; return IF; }
else { yylval = "ELSE"; return ELSE; }
while { yylval = "WHILE"; return WHILE; }
return { yylval = "RETURN"; return RETURN; }
\\x[^0-9a-fA-F]* {
    printf("Error type A at Line %d: unknown lexeme %s\n", yylineno, yytext);
}
'([^']|\\{valid_hex_int})' { yylval = yytext; return CHAR; }
";" { yylval = "SEMI"; return SEMI; }
"," { yylval = "COMMA"; return COMMA; }
"==" { yylval = "EQ"; return EQ; }
"<=" { yylval = "LE"; return LE; }
">=" { yylval = "GE"; return GE; }
"!=" { yylval = "NE"; return NE; }
"=" { yylval = "ASSIGN"; return ASSIGN; }
"!" { yylval = "NOT"; return NOT; }
"<" { yylval = "LT"; return LT; }
">" { yylval = "GT"; return GT; }
"+" { yylval = "PLUS"; return PLUS; }
"-" { yylval = "MINUS"; return MINUS; }
"*" { yylval = "MUL"; return MUL; }
"/" { yylval = "DIV"; return DIV; }
"&&" { yylval = "AND"; return AND; }
"||" { yylval = "OR"; return OR; }
"(" { yylval = "LP"; return LP; }
")" { yylval = "RP"; return RP; }
"[" { yylval = "LB"; return LB; }
"]" { yylval = "RB"; return RB; }
"{" { yylval = "LC"; return LC; }
"}" { yylval = "RC"; return RC; }
[_a-zA-Z][_0-9a-zA-Z]* { yylval = strdup(yytext); return ID; }
({valid_decimal_int})\.[0-9]+ { yylval = strdup(yytext); return FLOAT; }
{valid_decimal_int}|0{valid_hex_int} { yylval = strdup(yytext); return INT; /* not include minus number */ }
\\x(0|[1-9a-f][0-9a-f]*)[^0-9a-fA-F] {
    printf("Error type A at Line %d: unknown lexeme %s\n", yylineno, strdup(yytext));
}
"." { yylval = "DOT"; return DOT; }
0[Xx]([^0-9a-fA-F]|([1-9a-fA-F][0-9a-fA-F]*[^0-9a-fA-F]+)) {
    printf("Error type A at Line %d: unknown lexeme %s\n", yylineno, strdup(yytext));
}
[$@] {
    printf("Error type A at Line %d: unknown lexeme %s\n", yylineno, strdup(yytext));
}
%%
