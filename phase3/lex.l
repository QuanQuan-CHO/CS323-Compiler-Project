%{ 
    using namespace std;

    #include "syntax.tab.h"
%}

valid_decimal_int 0|[1-9][0-9]*
id [_a-zA-Z][_0-9a-zA-Z]*

%%
"//".* /*ignore single-line comment*/
"/*"(\*[^/]|[^*])*"*/" /*ignore multi-line comment*/
int|float|char {asprintf(&yylval,"TYPE: %s\n",yytext); return TYPE;}
struct {yylval=strdup("STRUCT\n"); return STRUCT;}
if {yylval=strdup("IF\n"); return IF;}
else {yylval=strdup("ELSE\n"); return ELSE;}
while {yylval=strdup("WHILE\n"); return WHILE;}
return {yylval=strdup("RETURN\n"); return RETURN;}
    /* Because CHAR is 2 Byte, only 1 or 2 hex char is allowed */
'([^']|\\[xX](0|[1-9a-fA-F][0-9a-fA-F]?))' {asprintf(&yylval,"CHAR: %s\n",yytext); return CHAR;}
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
"||" {yylval=strdup("OR\n"); return OR;}
"(" {yylval=strdup("LP\n"); return LP;}
")" {yylval=strdup("RP\n"); return RP;}
"[" {yylval=strdup("LB\n"); return LB;}
"]" {yylval=strdup("RB\n"); return RB;}
"{" {yylval=strdup("LC\n"); return LC;}
"}" {yylval=strdup("RC\n"); return RC;}
({valid_decimal_int})\.[0-9]+ {asprintf(&yylval,"FLOAT: %s\n",yytext); return FLOAT;}
{valid_decimal_int} {asprintf(&yylval,"INT: %s\n",yytext); return INT;/* not include minus number */}
0[xX](0|[1-9a-fA-F][0-9a-fA-F]*) {asprintf(&yylval,"INT: %lu\n",strtol(yytext,&yytext,16)); return INT;} /* valid_hex_int should be converted to decimal form */
{id} {asprintf(&yylval,"ID: %s\n",yytext); return ID;}
"." {yylval=strdup("DOT\n"); return DOT;}
\n {}
[ \r\t]+ /*ignore word splits*/

%%
