%{
    #include "lex.yy.c"
    void yyerror(const char*);
%}
%token STRUCT IF ELSE WHILE RETURN SEMI COMMA
%token EQ LE GE NE ASSIGN NOT LT GT PLUS MINUS MUL DIV AND OR
%token LP RP LB RB LC RC INT FLOAT CHAR ID TYPE DOT
%left MUL DIV AND OR LT LE GT GE NE EQ PLUS MINUS ASSIGN NOT DOT 
%right LB
%%

/* high-level definition */
/* global variable declarations and function definitions */
Program: ExtDefList
ExtDefList: 
    | ExtDef ExtDefList
ExtDef: Specifier ExtDecList SEMI
    | Specifier SEMI
    | Specifier FunDec CompSt
ExtDecList: VarDec
    | VarDec COMMA ExtDecList

/* specifier */
/* primitive types (int, float and char) and structure type */
Specifier: TYPE
    | StructSpecifier
StructSpecifier: STRUCT ID LC DefList RC
    | STRUCT ID

/* declarator */
/* variable and function declaration */
VarDec: ID
    | VarDec LB INT RB
FunDec: ID LP VarList RP
    | ID LP RP
VarList: ParamDec COMMA VarList
    | ParamDec
ParamDec: Specifier VarDec

/* statement */
/* specifies several program structures */
CompSt: LC DefList StmtList RC
StmtList:
    | Stmt StmtList
Stmt: Exp SEMI
    | CompSt
    | RETURN Exp SEMI
    | IF LP Exp RP Stmt
    | IF LP Exp RP Stmt ELSE Stmt
    | WHILE LP Exp RP Stmt

/* local definition */
/* declaration and assignment of local variables */
DefList:
    | Def DefList
Def: Specifier DecList SEMI
DecList: Dec
    | Dec COMMA DecList
Dec: VarDec
    | VarDec ASSIGN Exp

/* Expression */
/* a single constant, or operations on variables */
Exp: Exp ASSIGN Exp
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
    | LP Exp RP
    | MINUS Exp
    | NOT Exp
    | ID LP Args RP
    | ID LP RP
    | Exp LB Exp RB
    | Exp DOT ID
    | ID
    | INT
    | FLOAT
    | CHAR

Args: Exp COMMA Args
    | Exp


%%
void yyerror(const char* s) {
    fprintf(stderr, "%s\n", "Invalid");
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