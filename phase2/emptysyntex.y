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
    
    map imap;
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
  ExtDefList
| MacroStmt ExtDefList

MacroStmt:
  IncludeStmt
| DefineStmt
| DefineStmt MacroStmt
| IncludeStmt MacroStmt

IncludeStmt:
  INCLUDE LT MACRO GT
| INCLUDE DQUOT MACRO DQUOT

DefineStmt:
  DEFINE MACRO MACRO
| DefineStmt COMMA MACRO MACRO

ExtDefList:
  %empty
| ExtDef ExtDefList

ExtDef:
  Specifier ExtDecList SEMI 
| Specifier ExtDecList error
| Specifier SEMI
| Specifier error
| Specifier FunDec CompSt

ExtDecList:
  VarDec
| VarDec COMMA ExtDecList

Specifier:
  TYPE
| StructSpecifier

StructSpecifier:
  STRUCT ID LC DefList RC
| STRUCT ID LC DefList error
| STRUCT ID

VarDec:
  ID
| VarDec LB INT RB
| VarDec LB INT error
| VarDec INT RB

FunDec:
  ID LP VarList RP
| ID LP VarList error
| ID LP RP
| ID LP error

VarList:
  ParamDec COMMA VarList
| ParamDec

ParamDec:
  Specifier VarDec

CompSt:
  LC DefList StmtList RC
| LC DefList RC
| LC DefList error
| LC StmtList RC
| LC DefList StmtList error
| LC DefList StmtList DefList error

StmtList:
  Stmt
| Stmt StmtList

Stmt:
  Exp SEMI
| Exp error
| CompSt
| RETURN Exp SEMI
| RETURN Exp error
| RETURN error SEMI
| IF LP Exp RP Stmt %prec LOWER_ELSE
| IF LP Exp RP Stmt ELSE Stmt
| IF LP Exp error Stmt
| WHILE LP Exp RP Stmt
| WHILE LP Exp error Stmt
| FOR LP Exp SEMI Exp SEMI Exp RP Stmt
| IFDEF Stmt ENDIF
| IFDEF MACRO Stmt MACROELSE Stmt ENDIF

DefList:
  Def
| Def DefList

Def:
  Specifier DecList SEMI
| Specifier DecList error

DecList:
  Dec
| Dec COMMA DecList

Dec:
  VarDec
| VarDec ASSIGN Exp
| VarDec ASSIGN error

Exp:
  Exp ASSIGN Exp
| Exp AND Exp
| Exp OR Exp
| Exp LT Exp
| Exp LE Exp
| Exp GT Exp
| Exp GE Exp
| Exp NE Exp
| Exp EQ Exp
| Exp PLUS Exp
| Exp MINUS Exp
| Exp MUL Exp
| Exp DIV Exp
| Exp PLUS error
| Exp MINUS error
| Exp MUL error
| Exp DIV error
| LP Exp RP
| LP Exp error
| MINUS Exp
| NOT Exp
| ID LP Args RP
| ID LP Args error
| ID LP RP
| ID LP error
| Exp LB Exp RB
| Exp LB Exp error
| Exp DOT ID
| ID
| INT
| FLOAT
| CHAR
| STRING

Args:
  Exp COMMA Args
| Exp

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