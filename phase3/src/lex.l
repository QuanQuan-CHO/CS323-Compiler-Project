%{
    #include "syntax.tab.h"
%}

valid_decimal_int 0|[1-9][0-9]*
id [_a-zA-Z][_0-9a-zA-Z]*

%%
"//".* /*ignore single-line comment*/
"/*"(\*[^/]|[^*])*"*/" /*ignore multi-line comment*/
int|float|char {yylval=new node("TYPE"); return TYPE;}
struct {yylval=new node("STRUCT"); return STRUCT;}
if {yylval=new node("IF"); return IF;}
else {yylval=new node("ELSE"); return ELSE;}
while {yylval=new node("WHILE"); return WHILE;}
return {yylval=new node("RETURN"); return RETURN;}
for {yylval=new node("FOR"); return FOR;}
    /* Because CHAR is 2 Byte, only 1 or 2 hex char is allowed */
'([^']|\\[xX](0|[1-9a-fA-F][0-9a-fA-F]?))' {yylval=new node("CHAR"); return CHAR;}
";" {yylval=new node("SEMI"); return SEMI;}
"," {yylval=new node("COMMA"); return COMMA;}
"==" {yylval=new node("EQ"); return EQ;}
"<=" {yylval=new node("LE"); return LE;}
">=" {yylval=new node("GE"); return GE;}
"!=" {yylval=new node("NE"); return NE;}
"+=" {yylval=new node("PLUS_ASSIGN"); return PLUS_ASSIGN;}
"-=" {yylval=new node("MINUS_ASSIGN"); return MINUS_ASSIGN;}
"*=" {yylval=new node("MUL_ASSIGN"); return MUL_ASSIGN;}
"/=" {yylval=new node("DIV_ASSIGN"); return DIV_ASSIGN;}
"++" {yylval=new node("SELF_PLUS"); return SELF_PLUS;}
"--" {yylval=new node("SELF_MINUS"); return SELF_MINUS;}
"=" {yylval=new node("ASSIGN"); return ASSIGN;}
"!" {yylval=new node("NOT"); return NOT;}
"<" {yylval=new node("LT"); return LT;}
">" {yylval=new node("GT"); return GT;}
"+" {yylval=new node("PLUS"); return PLUS;}
"-" {yylval=new node("MINUS"); return MINUS;}
"*" {yylval=new node("MUL"); return MUL;}
"/" {yylval=new node("DIV"); return DIV;}
"&&" {yylval=new node("AND"); return AND;}
"||" {yylval=new node("OR"); return OR;}
"(" {yylval=new node("LP"); return LP;}
")" {yylval=new node("RP"); return RP;}
"[" {yylval=new node("LB"); return LB;}
"]" {yylval=new node("RB"); return RB;}
"{" {yylval=new node("LC"); return LC;}
"}" {yylval=new node("RC"); return RC;}
({valid_decimal_int})\.[0-9]+ {yylval=new node("FLOAT"); return FLOAT;}
{valid_decimal_int} { // not include minus number
    string text = yytext;
    yylval=new node("INT","#"+text); //constant in IR
    return INT;
}
0[xX](0|[1-9a-fA-F][0-9a-fA-F]*) {yylval=new node("INT","#"+to_string(strtol(yytext,&yytext,16))); return INT;} /* valid_hex_int should be converted to decimal form */
{id} {yylval=new node("ID",yytext); return ID;}
"." {yylval=new node("DOT"); return DOT;}
\n {}
[ \r\t]+ /*ignore word splits*/

%%
