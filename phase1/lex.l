%{
    #include "syntax.tab.h"
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
'([^']|\\{valid_hex_int})' {return CHAR;}
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
[_a-zA-Z][_0-9a-zA-Z]* {return ID;}
({valid_decimal_int})\.[0-9]+ {return FLOAT;}
{valid_decimal_int}|0{valid_hex_int} {return INT; /*not include minus number*/}
"."     {return DOT;}

%%
