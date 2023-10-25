%{  
    #define EXIT_OK 0
    #define EXIT_FAIL 1
    #include "string.h"
    #include "syntax.tab.h"
%}
%{
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

"//".* {}

"/*"((("*"[^/])?)|[^*])*"*/"  {}

int|float|char { 
    yylval.node = new Node("TYPE",strdup(yytext)); 
    return TYPE; }

\'(\\x{valid_hex_int}{2}|.)\' {
    yylval.node = new Node("CHAR",strdup(yytext));
    return CHAR;
}

"struct" { 
    yylval.node = new Node("STRUCT"); 
    return STRUCT; }

"if" {
    yylval.node = new Node("IF");
    return IF;
}

"else" {
    yylval.node = new Node("ELSE");
    return ELSE;
}

"while" {
    yylval.node = new Node("WHILE");
    return WHILE;
}

"return" {
    yylval.node = new Node("RETURN");
    return RETURN;
}

";" {
    yylval.node = new Node("SEMI");
    return SEMI;
}
"," {
    yylval.node = new Node("COMMA");
    return COMMA;
}
"==" {
    yylval.node = new Node("EQ");
    return EQ;
}
"<=" {
    yylval.node = new Node("LE");
    return LE;
}
">=" {
    yylval.node = new Node("GE");
    return GE;
}
"!=" {
    yylval.node = new Node("NE");
    return NE;
}
"=" {
    yylval.node = new Node("ASSIGN");
    return ASSIGN;
}
"!" {
    yylval.node = new Node("NOT");
    return NOT;
}
"<" {
    yylval.node = new Node("LT");
    return LT;
}
">" {
    yylval.node = new Node("GT");
    return GT;
}
"+" {
    yylval.node = new Node("PLUS");
    return PLUS;
}
"-" {
    yylval.node = new Node("MINUS");
    return MINUS;
}
"*" {
    yylval.node = new Node("MUL");
    return MUL;
}
"/" {
    yylval.node = new Node("DIV");
    return DIV;
}
"&&" {
    yylval.node = new Node("AND");
    return AND;
}
"||" {
    yylval.node = new Node("OR");
    return OR;
}
"(" {
    yylval.node = new Node("LP");
    return LP;
}
")" {
    yylval.node = new Node("RP");
    return RP;
}
"[" {
    yylval.node = new Node("LB");
    return LB;
}
"]" {
    yylval.node = new Node("RB");
    return RB;
}
"{" {
    yylval.node = new Node("LC");
    return LC;
}
"}" {
    yylval.node = new Node("RC");
    return RC;
}

[_a-zA-Z][_0-9a-zA-Z]* { 
    yylval.node = new Node("ID",strdup(yytext)); 
    return ID; }

({valid_decimal_int})\.[0-9]+ { 
    yylval.node = new Node("FLOAT", (float)atof(yytext)); 
    return FLOAT; }

{valid_decimal_int}|0{valid_hex_int} { 
    yylval.node = new Node("INT", atoi(yytext)); 
    return INT; /* not include minus number */ }

"." { 
    yylval.node = new Node("DOT");
    return DOT; }

\\x(0|[1-9a-f][0-9a-f]*)[^0-9a-fA-F] {
    printf("Error type A at Line %d: unknown lexeme %s\n", yylineno, strdup(yytext));
}

0[Xx]([^0-9a-fA-F]|([1-9a-fA-F][0-9a-fA-F]*[^0-9a-fA-F]+)) {
    printf("Error type A at Line %d: unknown lexeme %s\n", yylineno, strdup(yytext));
}
[$@] {
    printf("Error type A at Line %d: unknown lexeme %s\n", yylineno, strdup(yytext));
}
\\x[^0-9a-fA-F]* {
    printf("Error type A at Line %d: unknown lexeme %s\n", yylineno, yytext);
}

\n { yycolno = 1;}

" " {}
%%
   
   