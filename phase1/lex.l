%{
    #include "syntax.tab.h"
%}

%option yylineno

letter [a-zA-Z]
digit [0-9]

%%
    /*handle comment*/
    /*handle string*/
struct  {return STRUCT;}
if      {return IF;}
else    {return ELSE;}
while   {return WHILE;}
return  {return RETURN;}
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
0|[1-9][0-9]*|0[xX](0|[1-9][0-9a-f]*) {return INT; printf("%d %s\n",yylineno,yytext);/*not include minus number*/}
"."     {return DOT;}

%%
