%{
    #define EXIT_OK 0
    #define EXIT_FAIL 1
    #define YYSTYPE char *
    #include "string.h"
    #include "syntax.tab.h"
%}
%{
/* library inclusions */
int yycolno = 1;
#define YY_USER_ACTION \
yylloc.first_line = yylineno; \
yylloc.first_column = yycolno; \
yylloc.last_line = yylineno; \
yylloc.last_column = yycolno + yyleng; \
yycolno += yyleng;
%}

%option yylineno
%option debug

valid_decimal_int 0|[1-9][0-9]*
valid_hex_int [xX](0|[1-9a-f][0-9a-f]*)

%%
    /*TODO: handle comment*/
    /*TODO: handle string*/
int|float|char {return TYPE;}
struct  {return STRUCT;}
if      {return IF;}
else    {return ELSE;}
while   {return WHILE;}
return  {return RETURN;}
'([^']|\\{valid_hex_int})' {yylval = yytext;return CHAR;}
";"     {return SEMI;}
","     {return COMMA;}
"=="    {return EQ;}
"<="    {return LE;}
">="    {return GE;}
"!="    {return NE;}
"="     {return ASSIGN;}
"!"     {return NOT;}
"<"     {return LT;}
">"     {return GT;}
"+"     {return PLUS;}
"-"     {return MINUS;}
"*"     {return MUL;}
"/"     {return DIV;}
"&&"    {return AND;}
"||"    {return OR;}
"("     {return LP;}
")"     {return RP;}
"["     {return LB;}
"]"     {return RB;}
"{"     {return LC;}
"}"     {return RC;}
[_a-zA-Z][_0-9a-zA-Z]* {yylval = yytext; return ID;}
({valid_decimal_int})\.[0-9]+ {yylval = yytext;return FLOAT;}
{valid_decimal_int}|0{valid_hex_int} {yylval = yytext;return INT; /*not include minus number*/}
"."     {return DOT;}
"\n" { yycolno = 1; }
"//" { char c; while((c=input()) != '\n'); }
%%
