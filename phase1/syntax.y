%{  #include "tree.hpp"
    #include "lex.yy.c"
    #include <stdlib.h>
    #include <stdio.h>
    extern int yylineno;
    void yyerror(const char*);
%}

%locations

%union {
    Node* node;
}

%nonassoc LOWER_ELSE
%nonassoc <node> ELSE

%token <node> STRUCT IF WHILE RETURN SEMI COMMA
%token <node> EQ LE GE NE ASSIGN NOT LT GT PLUS MINUS MUL DIV AND OR
%token <node> LP RP LB RB LC RC DOT INT FLOAT CHAR ID TYPE
%left ASSIGN
%left OR
%left AND
%left EQ NE
%left LT GT LE GE
%left PLUS MINUS
%left MUL DIV
%right NOT
%left DOT
%left LB RB

%type <node> Program ExtDefList ExtDef ExtDecList
%type <node> Specifier StructSpecifier 
%type <node> VarDec FunDec VarList ParamDec CompSt StmtList
%type <node> Stmt DefList Def DecList Dec Exp Args

%%

/* high-level definition */
/* global variable declarations and function definitions */

Program: ExtDefList {
    $$=new Node("Program",1,@$.first_line,$1);
    printTree($$);
}
ExtDefList: %empty {$$=new Node("ExtDefList");}
    | ExtDef ExtDefList {$$=new Node("ExtDefList",2,@$.first_line,$1,$2);}
ExtDef: Specifier ExtDecList SEMI { $$=new Node("ExtDef",3,@$.first_line,$1,$2,$3);}
    | Specifier SEMI { $$=new Node("ExtDef",2,@$.first_line,$1,$2);}
    | Specifier FunDec CompSt { $$=new Node("ExtDef",3,@$.first_line,$1,$2,$3);}
ExtDecList: VarDec {$$=new Node("ExtDecList",1,@$.first_line,$1);}
    | VarDec COMMA ExtDecList { $$=new Node("ExtDecList",3,@$.first_line,$1,$2,$3);}

/* specifier */
/* primitive types (int, float and char) and structure type */
Specifier: TYPE {$$=new Node("Specifier",1,@$.first_line,$1);}
    | StructSpecifier {$$=new Node("Specifier",1,@$.first_line,$1);}
StructSpecifier: STRUCT ID LC DefList RC {$$=new Node("StructSpecifier", 5, @$.first_line, $1, $2, $3, $4, $5);}
    | STRUCT ID { $$=new Node("StructSpecifier",2,@$.first_line,$1,$2);}

/* declarator */
/* variable and function declaration */
VarDec: ID {$$=new Node("VarDec",1,@$.first_line,$1); }
    | VarDec LB INT RB { $$=new Node("VarDec",4,@$.first_line,$1,$2,$3,$4);}
FunDec: ID LP VarList RP { $$=new Node("FunDec",4,@$.first_line,$1,$2,$3,$4);}
    | ID LP RP {$$=new Node("FunDec",3,@$.first_line,$1,$2,$3);}
VarList: ParamDec COMMA VarList {$$=new Node("VarList",3,@$.first_line,$1,$2,$3);}
    | ParamDec { $$=new Node("VarList",1,@$.first_line,$1);}
ParamDec: Specifier VarDec { $$=new Node("ParamDec",2,@$.first_line,$1,$2);}

/* statement */
/* specifies several program structures */
/*Here is a change on DefList, may need to deal*/
/*deflist is empty now!*/
CompSt: LC DefList StmtList RC {$$=new Node("CompSt",4,@$.first_line,$1,$2,$3,$4);}
StmtList: 
    %empty
    {$$=new Node("StmtList",@$.first_line);}
    | Stmt StmtList { $$=new Node("StmtList",2,@$.first_line,$1,$2);}


Stmt: Exp SEMI {$$=new Node("Stmt",2,@$.first_line,$1,$2);}
    | CompSt {$$=new Node("Stmt",1,@$.first_line,$1);}
    | RETURN Exp SEMI {$$=new Node("Stmt",3,@$.first_line,$1,$2,$3);}
    | WHILE LP Exp RP Stmt {$$=new Node("Stmt", 5, @$.first_line, $1, $2, $3, $4, $5);}
    | IF LP Exp RP Stmt %prec LOWER_ELSE {$$=new Node("Stmt", 5, @$.first_line, $1, $2, $3, $4, $5);}
    | IF LP Exp RP Stmt ELSE Stmt {$$=new Node( "Stmt", 7, @$.first_line, $1, $2, $3, $4, $5, $6, $7);}

/* local definition */
/* declaration and assignment of local variables */
DefList: %empty{$$=new Node("DefList",@$.first_line);}
    | Def DefList {$$=new Node("DefList",2,@$.first_line,$1,$2);}
Def: Specifier DecList SEMI {$$=new Node("Def",3,@$.first_line,$1,$2,$3);}
DecList: Dec {$$=new Node("DecList",1,@$.first_line,$1);}
    | Dec COMMA DecList {$$=new Node("DecList",3,@$.first_line,$1,$2,$3);}

Dec: VarDec {$$=new Node("Dec",1,@$.first_line,$1);}
    | VarDec ASSIGN Exp {$$=new Node("Dec",3,@$.first_line,$1,$2,$3);}

/* Expression */
/* a single constant, or operations on variables */
Exp: Exp ASSIGN Exp {$$=new Node("Exp",3,@$.first_line,$1,$2,$3);}
    | Exp AND Exp {$$=new Node("Exp",3,@$.first_line,$1,$2,$3);}
    | Exp OR Exp {$$=new Node("Exp",3,@$.first_line,$1,$2,$3);}
    | Exp LT Exp {$$=new Node("Exp",3,@$.first_line,$1,$2,$3);}
    | Exp LE Exp {$$=new Node("Exp",3,@$.first_line,$1,$2,$3);}
    | Exp GT Exp {$$=new Node("Exp",3,@$.first_line,$1,$2,$3);}
    | Exp GE Exp {$$=new Node("Exp",3,@$.first_line,$1,$2,$3);}
    | Exp NE Exp {$$=new Node("Exp",3,@$.first_line,$1,$2,$3);}
    | Exp EQ Exp {$$=new Node("Exp",3,@$.first_line,$1,$2,$3);}
    | Exp PLUS Exp {$$=new Node("Exp",3,@$.first_line,$1,$2,$3);}
    | Exp MINUS Exp {$$=new Node("Exp",3,@$.first_line,$1,$2,$3);}
    | Exp MUL Exp {$$=new Node("Exp",3,@$.first_line,$1,$2,$3);}
    | Exp DIV Exp {$$=new Node("Exp",3,@$.first_line,$1,$2,$3);}
    | LP Exp RP {$$=new Node("Exp",3,@$.first_line,$1,$2,$3);}
    | MINUS Exp {$$=new Node("Exp",2,@$.first_line,$1,$2);}
    | NOT Exp {$$=new Node("Exp",2,@$.first_line,$1,$2);}
    | ID LP Args RP {$$=new Node("Exp",4,@$.first_line,$1,$2,$3,$4);}
    | ID LP RP {$$=new Node("Exp",3,@$.first_line,$1,$2,$3);}
    | Exp LB Exp RB {$$=new Node("Exp",4,@$.first_line,$1,$2,$3,$4);}
    | Exp DOT ID {$$=new Node("Exp",3,@$.first_line,$1,$2,$3);}
    | ID {$$=new Node("Exp",1,@$.first_line,$1);}
    | INT {$$=new Node("Exp",1,@$.first_line,$1);}
    | FLOAT {$$=new Node("Exp",1,@$.first_line,$1);}
    | CHAR {$$=new Node("Exp",1,@$.first_line,$1);}

Args: Exp COMMA Args {$$=new Node("Args",3,@$.first_line,$1,$2,$3);}
    | Exp {$$=new Node("Args",1,@$.first_line,$1);}

%%
void yyerror(const char *s) {
    fprintf(stderr, "%s\n", s);
}

int main(int argc, char **argv){
    char *file_path;
    if(argc < 2){
        fprintf(stderr, "Usage: %s <file_path>\n", argv[0]);
        return EXIT_FAIL;
    } else if(argc == 2){
        file_path = argv[1];
        if(!(yyin = fopen(file_path, "r"))){
            perror(argv[1]);
            return EXIT_FAIL;
        }
        yyparse();
        return EXIT_OK;
    } else{
        fputs("Too many arguments! Expected: 2.\n", stderr);
        return EXIT_FAIL;
    }
}