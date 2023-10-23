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
int|float|char {yylval = strdup(yytext); return TYPE;}
struct  {yylval = "STRUCT\n"; return STRUCT;}
if      {yylval = "IF\n"; return IF;}
else    {yylval = "ELSE\n"; return ELSE;}
while   {yylval = "WHILE\n"; return WHILE;}
return  {yylval = "RETURN\n"; return RETURN;}
\\x[^0-9a-fA-F]* {
    printf("Error type A at Line %d: unknown lexeme %s\n",
               yylineno, yytext);
}
'([^']|\\{valid_hex_int})' {yylval = yytext; return CHAR;}
";"     {yylval = "SEMI\n"; return SEMI;}
","     {yylval = "COMMA\n"; return COMMA;}
"=="    {yylval = "EQ\n"; return EQ;}
"<="    {yylval = "LE\n"; return LE;}
">="    {yylval = "GE\n"; return GE;}
"!="    {yylval = "NE\n"; return NE;}
"="     {yylval = "ASSIGN\n"; return ASSIGN;}
"!"     {yylval = "NOT\n"; return NOT;}
"<"     {yylval = "LT\n"; return LT;}
">"     {yylval = "GT\n"; return GT;}
"+"     {yylval = "PLUS\n"; return PLUS;}
"-"     {yylval = "MINUS\n"; return MINUS;}
"*"     {yylval = "MUL\n"; return MUL;}
"/"     {yylval = "DIV\n"; return DIV;}
"&&"    {yylval = "AND\n"; return AND;}
"||"    {yylval = "OR\n"; return OR;}
"("     {yylval = "LP\n"; return LP;}
")"     {yylval = "RP\n"; return RP;}
"["     {yylval = "LB\n"; return LB;}
"]"     {yylval = "RB\n"; return RB;}
"{"     {yylval = "LC\n"; return LC;}
"}"     {yylval = "RC\n"; return RC;}
[_a-zA-Z][_0-9a-zA-Z]* {yylval = strdup(yytext); return ID;}
({valid_decimal_int})\.[0-9]+ {yylval = strdup(yytext);return FLOAT;}
{valid_decimal_int}|0{valid_hex_int} {yylval = strdup(yytext);return INT; /*not include minus number*/}
\\x(0|[1-9a-f][0-9a-f]*)[^0-9a-fA-F] {
    printf("Error type A at Line %d: unknown lexeme %s\n",
               yylineno, strdup(yytext));
}
"."     {yylval = "DOT\n";return DOT;}
"\n" { yycolno = 1; }
0[Xx]([^0-9a-fA-F]|([1-9a-fA-F][0-9a-fA-F]*[^0-9a-fA-F]+)) {
    printf("Error type A at Line %d: unknown lexeme %s\n",
               yylineno, strdup(yytext));
}
[$@] {
    printf("Error type A at Line %d: unknown lexeme %s\n",
               yylineno, strdup(yytext));}

%%
