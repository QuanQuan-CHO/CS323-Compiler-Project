%{
    #include "lex.yy.c"
    void yyerror(const char*);
%}
%token STRUCT IF ELSE WHILE RETURN SEMI COMMA EQ LE GE NE ASSIGN NOT LT GT PLUS MINUS MUL DIV AND OR LP RP LB RB LC RC INT FLOAT CHAR ID TYPE DOT

%%

Temp: INT

%%

int main() {
    yyparse();
}
