%{    
    #include "err.hpp"
    #include "lex.yy.c"
    extern int yylineno;
    bool has_error=false; //Has lexical or syntax error
    void yyerror(const char*){}
    void syntax_error(const char* missing_token, int lineno){
        has_error=true;
        printf("Error type B at Line %d: Missing %s\n", lineno, missing_token);
    }
%}

%union{
    rec* rec_ptr;
}

%nonassoc <rec_ptr> LOWER_ELSE
%nonassoc <rec_ptr> ELSE

%token <rec_ptr> TYPE INT CHAR FLOAT STRING STRUCT ID
%token <rec_ptr> IF WHILE RETURN /*control flow word*/
%token <rec_ptr> COMMA

%token <rec_ptr> FOR 
%token <rec_ptr> IFDEF MACROELSE ENDIF
%token <rec_ptr> INCLUDE DQUOT
%token <rec_ptr> DEFINE MACRO

%right <rec_ptr> ASSIGN
%left  <rec_ptr> OR
%left  <rec_ptr> AND
%left <rec_ptr> EQ NE
%left <rec_ptr> LT GT LE GE
%left <rec_ptr>  PLUS MINUS
%left <rec_ptr> MUL DIV
%right <rec_ptr> NOT
%left <rec_ptr> DOT
%left <rec_ptr> LP RP LB RB

%token <rec_ptr> SEMI LC RC /*punctuation word*/
/* Non terminal */
%type <rec_ptr> Program ExtDefList ExtDef ExtDecList
%type <rec_ptr> Specifier StructSpecifier 
%type <rec_ptr> VarDec FunDec VarList ParamDec CompSt StmtList
%type <rec_ptr> Stmt DefList Def DecList Dec Exp Args
%%

Program:
  ExtDefList {if(!has_error){printf("Program (%d)\n", @$.first_line);}}
| MacroStmt ExtDefList {if(!has_error){printf("Program (%d)\n", @$.first_line);}}

MacroStmt:
  IncludeStmt {printf("MacroStmt (%d)\n", @$.first_line);}
| DefineStmt {printf("MacroStmt (%d)\n", @$.first_line);}
| DefineStmt MacroStmt {printf("MacroStmt (%d)\n", @$.first_line);}
| IncludeStmt MacroStmt {printf("MacroStmt (%d)\n", @$.first_line);}

IncludeStmt:
  INCLUDE LT MACRO GT {printf("IncludeStmt (%d)\n", @$.first_line);}
| INCLUDE DQUOT MACRO DQUOT {printf("IncludeStmt (%d)\n", @$.first_line);}

DefineStmt:
  DEFINE MACRO MACRO {printf("DefineStmt (%d)\n", @$.first_line);}
| DefineStmt COMMA MACRO MACRO {printf("DefineStmt (%d)\n", @$.first_line);}

ExtDefList:
  %empty {}
| ExtDef ExtDefList {}

ExtDef:
  Specifier ExtDecList SEMI {}
| Specifier ExtDecList error {syntax_error("semicolon \';\'", @2.last_line);}
| Specifier SEMI {}
| Specifier error {syntax_error("semicolon \';\'", @1.last_line);}
| Specifier FunDec CompSt {$2->val=$1;}//progress

ExtDecList:
  VarDec {$$=new rec(noact);$$->link(1,$1);}
| VarDec COMMA ExtDecList {$3->link(1,$1);$$=$3;}

Specifier:
  TYPE {$$=$1;}
| StructSpecifier {$$=$1;}

StructSpecifier:
  STRUCT ID LC DefList RC {$$=new rec(noact); rec* dstr=new rec(def); $2->t=structvar; dstr->link(1,$2); $$->link(2,dstr,$4);}
| STRUCT ID LC DefList error {syntax_error("closing curly brace \'}\'",@4.last_line);}
| STRUCT ID {$2->t=structvar;$$=$2;}

VarDec:
  ID {$$=$1;}
| VarDec LB INT RB {$1->arr=true;$$=$1;} //arr declare
| VarDec LB INT error {syntax_error("closing bracket \']\'",@3.last_line);}
| VarDec INT RB {syntax_error("closing bracket \'[\'",@3.last_line);}
| VarDec LB error RB {} //throw err

FunDec:
  ID LP VarList RP {rec* cfun=new rec(def); $1->fun=true; cfun->link(1,$1); $$=new rec(noact);$$->link(2,cfun,$3);}
| ID LP VarList error {syntax_error("closing parenthesis \')\'",@3.last_line);}
| ID LP RP {$$=new rec(def);$1->fun=true; $$->link(1,$1);}
| ID LP error {syntax_error("closing parenthesis \')\'",@2.last_line);}

VarList:
  ParamDec COMMA VarList {$3->link(1,$1);$$=$3;}
| ParamDec {$$=new rec(noact);$$->link(1,$1);}

ParamDec:
  Specifier VarDec {$$=new rec(def);$2->t=$1->t; $$->link(1,$2);}

CompSt:
  LC DefList StmtList RC {$$=new rec(noact);$$->link(2,$2,$3);}
| LC DefList StmtList error {syntax_error("closing curly brace \'}\'",@3.last_line);}
| LC DefList RC {$$=$2;}
| LC DefList error {syntax_error("closing curly brace \'}\'",@2.last_line);}
| LC StmtList RC {$$=$2;}
| LC StmtList error {syntax_error("closing curly brace \'}\'",@2.last_line);}
| LC DefList StmtList DefList error {syntax_error("specifier",@3.first_line);}

StmtList:
  Stmt {$$=new rec(noact);$$->link(1,$1);}
| Stmt StmtList {$2->link(1,$1);$$=$2;}

Stmt:
  Exp SEMI {$$=$1;}
| Exp error {syntax_error("semicolon \';\'",@1.last_line);}
| CompSt {$$=new rec(noact);}
| RETURN Exp SEMI {$$=new rec(noact);$$->link(1,$2);$$->val=$2;$$->t=var;}
| RETURN Exp error {syntax_error("semicolon \';\'",@2.last_line);}
| RETURN error SEMI {}
| IF LP Exp RP Stmt %prec LOWER_ELSE {$$=new rec(noact);$$->link(2,$3,$5);}
| IF LP Exp RP Stmt ELSE Stmt {$$=new rec(noact);$$->link(3,$3,$5,$7);}
| IF LP Exp error Stmt {syntax_error("closing parenthesis \')\'",@3.last_line);}
| WHILE LP Exp RP Stmt {$$=new rec(noact);$$->link(2,$3,$5);}
| WHILE LP Exp error Stmt {syntax_error("closing parenthesis \')\'",@3.last_line);}
| FOR LP Exp SEMI Exp SEMI Exp RP Stmt {$$=new rec(noact);$$->link(4,$3,$5,$7,$9);}
| IFDEF Stmt ENDIF {$$=$2;}
| IFDEF MACRO Stmt MACROELSE Stmt ENDIF {$$=new rec(noact);$$->link(2,$3,$5);}

DefList:
  Def {$$=new rec(noact);$$->link(1,$1);}
| Def DefList {$2->link(1,$1);$$=$2;}

Def:
  Specifier DecList SEMI {$$=new rec(def);set_type($1->t,$2->recs);} //def muti var
| Specifier DecList error {syntax_error("semicolon \';\'",@2.last_line);}

DecList:
  Dec {$$=new rec(noact);$$->link(1,$1);}
| Dec COMMA DecList {$3->link(1,$1); $$=$3;}

Dec:
  VarDec {$$=$1;}
| VarDec ASSIGN Exp {$$=new rec(usassign);$$->link(2,$1,$3);}
| VarDec ASSIGN error {}

Exp:
  Exp ASSIGN Exp {$$=new rec(usassign);$$->link(2,$1,$3);}
| Exp AND Exp {$$=new rec(usop);$$->link(3,$1,$2,$3);}
| Exp OR Exp {$$=new rec(usop);$$->link(3,$1,$2,$3);}
| Exp LT Exp {$$=new rec(usop);$$->link(3,$1,$2,$3);}
| Exp LE Exp {$$=new rec(usop);$$->link(3,$1,$2,$3);}
| Exp GT Exp {$$=new rec(usop);$$->link(3,$1,$2,$3);}
| Exp GE Exp {$$=new rec(usop);$$->link(3,$1,$2,$3);}
| Exp NE Exp {$$=new rec(usop);$$->link(3,$1,$2,$3);}
| Exp EQ Exp {$$=new rec(usop);$$->link(3,$1,$2,$3);}
| Exp PLUS Exp {$$=new rec(usop);$$->link(3,$1,$2,$3);}
| Exp MINUS Exp {$$=new rec(usop);$$->link(3,$1,$2,$3);}
| Exp MUL Exp {$$=new rec(usop);$$->link(3,$1,$2,$3);}
| Exp DIV Exp {$$=new rec(usop);$$->link(3,$1,$2,$3);}

| Exp PLUS error {syntax_error("Exp after +",@3.last_line);}
| Exp MINUS error {syntax_error("Exp after -",@3.last_line);}
| Exp MUL error {syntax_error("Exp after *",@3.last_line);}
| Exp DIV error {syntax_error("Exp after /",@3.last_line);}

| LP Exp RP {$$=$1;}
| LP Exp error {syntax_error("closing parenthesis \')\'",@2.last_line);}
| MINUS Exp {$$=new rec(usop);$$->link(2,$1,$2);}
| NOT Exp {$$=new rec(usop);$$->link(2,$1,$2);}
| ID LP Args RP {$$=new rec(usfun);$$->link(2,$1,$3);}
| ID LP Args error {syntax_error("closing parenthesis \')\'",@3.last_line);}
| ID LP RP {$$=new rec(usfun);$$->link(1,$1);}
| ID LP error {syntax_error("closing parenthesis \')\'",@2.last_line);}
| Exp LB Exp RB {$$=new rec(usarr);$$->link(2,$1,$3);}
| Exp LB Exp error {syntax_error("closing bracket \']\'",@3.last_line);}
| Exp DOT ID {$$=new rec(usstruct);$$->link(2,$1,$3);}
| ID {$$=$1;}
| INT {$$=$1;}
| FLOAT {$$=$1;}
| CHAR {$$=$1;}
| STRING {$$=$1;}

Args:
  Exp COMMA Args {$3->link(1,$1); $$=$3;}
| Exp {$$=new rec(noact);$$->link(1,$1);}

%%

int main(int argc, char **argv){
    char *file_path;
    if(argc < 2){
        fprintf(stderr, "Usage: %s <file_path>\n", argv[0]);
        return 1;
    } else if(argc == 2){
        file_path = argv[1];
        if(!(yyin = fopen(file_path, "r"))){
            perror(argv[1]);
            return 1;
        }
        yyparse();
        return 0;
    } else{
        fputs("Too many arguments! Expected: 2.\n", stderr);
        return 1;
    }
}
