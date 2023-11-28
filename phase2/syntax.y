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
| Specifier FunDec CompSt {}

ExtDecList:
  VarDec {}
| VarDec COMMA ExtDecList {}

Specifier:
  TYPE {}
| StructSpecifier {}

StructSpecifier:
  STRUCT ID LC DefList RC {}
| STRUCT ID LC DefList error {syntax_error("closing curly brace \'}\'",@4.last_line);}
| STRUCT ID {}

VarDec:
  ID {}
| VarDec LB INT RB {}
| VarDec LB INT error {syntax_error("closing bracket \']\'",@3.last_line);}
| VarDec INT RB {syntax_error("closing bracket \'[\'",@3.last_line);}

FunDec:
  ID LP VarList RP {}
| ID LP VarList error {syntax_error("closing parenthesis \')\'",@3.last_line);}
| ID LP RP {}
| ID LP error {syntax_error("closing parenthesis \')\'",@2.last_line);}

VarList:
  ParamDec COMMA VarList {}
| ParamDec {}

ParamDec:
  Specifier VarDec {}

CompSt:
  LC DefList StmtList RC {}
| LC DefList StmtList error {syntax_error("closing curly brace \'}\'",@3.last_line);}
| LC DefList RC {}
| LC DefList error {syntax_error("closing curly brace \'}\'",@2.last_line);}
| LC StmtList RC {}
| LC StmtList error {syntax_error("closing curly brace \'}\'",@2.last_line);}
| LC DefList StmtList DefList error {syntax_error("specifier",@3.first_line);}

StmtList:
  Stmt {}
| Stmt StmtList {}

Stmt:
  Exp SEMI {}
| Exp error {syntax_error("semicolon \';\'",@1.last_line);}
| CompSt {}
| RETURN Exp SEMI {}
| RETURN Exp error {syntax_error("semicolon \';\'",@2.last_line);}
| RETURN error SEMI {}
| IF LP Exp RP Stmt %prec LOWER_ELSE {}
| IF LP Exp RP Stmt ELSE Stmt {}
| IF LP Exp error Stmt {syntax_error("closing parenthesis \')\'",@3.last_line);}
| WHILE LP Exp RP Stmt {}
| WHILE LP Exp error Stmt {syntax_error("closing parenthesis \')\'",@3.last_line);}
| FOR LP Exp SEMI Exp SEMI Exp RP Stmt {}
| IFDEF Stmt ENDIF {}
| IFDEF MACRO Stmt MACROELSE Stmt ENDIF {}

DefList:
  Def {}
| Def DefList {}

Def:
  Specifier DecList SEMI {}
| Specifier DecList error {syntax_error("semicolon \';\'",@2.last_line);}

DecList:
  Dec {}
| Dec COMMA DecList {}

Dec:
  VarDec {}
| VarDec ASSIGN Exp {}
| VarDec ASSIGN error {}

Exp:
  Exp ASSIGN Exp {}
| Exp AND Exp {}
| Exp OR Exp {}
| Exp LT Exp {}
| Exp LE Exp {}
| Exp GT Exp {}
| Exp GE Exp {}
| Exp NE Exp {}
| Exp EQ Exp {}
| Exp PLUS Exp {}
| Exp MINUS Exp {}
| Exp MUL Exp {}
| Exp DIV Exp {}

| Exp PLUS error {syntax_error("Exp after +",@3.last_line);}
| Exp MINUS error {syntax_error("Exp after -",@3.last_line);}
| Exp MUL error {syntax_error("Exp after *",@3.last_line);}
| Exp DIV error {syntax_error("Exp after /",@3.last_line);}

| LP Exp RP {}
| LP Exp error {syntax_error("closing parenthesis \')\'",@2.last_line);}
| MINUS Exp {}
| NOT Exp {}
| ID LP Args RP {}
| ID LP Args error {syntax_error("closing parenthesis \')\'",@3.last_line);}
| ID LP RP {}
| ID LP error {syntax_error("closing parenthesis \')\'",@2.last_line);}
| Exp LB Exp RB {}
| Exp LB Exp error {syntax_error("closing bracket \']\'",@3.last_line);}
| Exp DOT ID {}
| ID {}
| INT {}
| FLOAT {}
| CHAR {}
| STRING {}

Args:
  Exp COMMA Args {$$=new rec($3);}
| Exp {$$=new rec($1);}

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
