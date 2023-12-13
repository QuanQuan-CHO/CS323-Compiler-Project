%{ 
    #include "syntax.tab.h"
%}

valid_decimal_int 0|[1-9][0-9]*
id [_a-zA-Z][_0-9a-zA-Z]*

%%
"//".* /*ignore single-line comment*/
"/*"(\*[^/]|[^*])*"*/" /*ignore multi-line comment*/
int|float|char {return TYPE;}
struct {return STRUCT;}
if {return IF;}
else {return ELSE;}
while {return WHILE;}
return {return RETURN;}
    /* Because CHAR is 2 Byte, only 1 or 2 hex char is allowed */
'([^']|\\[xX](0|[1-9a-fA-F][0-9a-fA-F]?))' {return CHAR;}
";" {return SEMI;}
"," {return COMMA;}
"==" {return EQ;}
"<=" {return LE;}
">=" {return GE;}
"!=" {return NE;}
"=" {return ASSIGN;}
"!" {return NOT;}
"<" {return LT;}
">" {return GT;}
"+" {return PLUS;}
"-" {return MINUS;}
"*" {return MUL;}
"/" {return DIV;}
"&&" {return AND;}
"||" {return OR;}
"(" {return LP;}
")" {return RP;}
"[" {return LB;}
"]" {return RB;}
"{" {return LC;}
"}" {return RC;}
({valid_decimal_int})\.[0-9]+ {return FLOAT;}
{valid_decimal_int} {return INT;/* not include minus number */}
0[xX](0|[1-9a-fA-F][0-9a-fA-F]*) {yylval=strtol(yytext,&yytext,16); return INT;} /* valid_hex_int should be converted to decimal form */
{id} {yylval=yytext; return ID;}
"." {return DOT;}
\n {}
[ \r\t]+ /*ignore word splits*/

%%
