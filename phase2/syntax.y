%{
    using namespace std;

    #define YYSTYPE char* //Define the type of `yylval`

    #include "lex.yy.c"
    #include "symbol.hpp"
    extern int yylineno;
    bool has_error=false; //Has lexical or syntax error
    void yyerror(const char*){}
    
    //concat the strings and shift two spaces
    template<typename... Args>
    char* concat_shift(Args... strs) {
        //1.concat the strings
        char* concat = strdup("");
        (asprintf(&concat,"%s%s",concat,strs), ...);

        //2.shift two spaces in each line
        char* result = strdup("");
        char* line=strtok(concat,"\n");
        while(line!=NULL){
            asprintf(&result,"%s  %s\n",result,line);
            line=strtok(NULL,"\n");
        }
        return result;
    }
    void syntax_error(const char* missing_token, int lineno){
        has_error=true;
        printf("Error type B at Line %d: Missing %s\n", lineno, missing_token);
    }

%}

%nonassoc LOWER_ELSE
%nonassoc ELSE

%token TYPE INT CHAR FLOAT STRING STRUCT ID
%token IF WHILE RETURN /*control flow word*/
%token COMMA

%token FOR 
%token IFDEF MACROELSE ENDIF
%token INCLUDE DQUOT
%token DEFINE MACRO

%right ASSIGN
%left OR
%left AND
%left EQ NE
%left LT GT LE GE
%left PLUS MINUS
%left MUL DIV
%right NOT
%left DOT
%left LP RP LB RB

%token SEMI LC RC /*punctuation word*/
%%

/* HIGH-LEVEL DEFINITION specifies the top-level syntax for a SPL program, including global variable declarations and function definitions.*/
Program:
  ExtDefList {if(!has_error){printf("Program (%d)\n%s", @$.first_line, concat_shift($1));}}
| MacroStmt ExtDefList {if(!has_error){printf("Program (%d)\n%s", @$.first_line, concat_shift($1,$2));}}

MacroStmt:
  IncludeStmt {asprintf(&$$,"MacroStmt (%d)\n%s\n", @$.first_line, concat_shift($1));}
| DefineStmt {asprintf(&$$,"MacroStmt (%d)\n%s\n", @$.first_line, concat_shift($1));}
| DefineStmt MacroStmt {asprintf(&$$,"MacroStmt (%d)\n%s\n", @$.first_line, concat_shift($1,$2));}
| IncludeStmt MacroStmt {asprintf(&$$,"MacroStmt (%d)\n%s\n", @$.first_line, concat_shift($1,$2));}

IncludeStmt:
  INCLUDE LT MACRO GT {asprintf(&$$,"IncludeStmt (%d)\n%s", @$.first_line, concat_shift($1,$2,$3,$4));}
| INCLUDE DQUOT MACRO DQUOT {asprintf(&$$,"IncludeStmt (%d)\n%s", @$.first_line, concat_shift($1,$2,$3,$4));}

DefineStmt:
  DEFINE MACRO MACRO {asprintf(&$$,"DefineStmt (%d)\n%s", @$.first_line, concat_shift($1,$2,$3));}
| DefineStmt COMMA MACRO MACRO {asprintf(&$$,"DefineStmt (%d)\n%s", @$.first_line, concat_shift($1,$2,$3));}

ExtDefList:
  %empty {$$=strdup("");}
| ExtDef ExtDefList {asprintf(&$$,"ExtDefList (%d)\n%s\n", @$.first_line, concat_shift($1,$2));}

ExtDef:
  Specifier ExtDecList SEMI {asprintf(&$$,"ExtDef (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3));}
| Specifier ExtDecList error {syntax_error("semicolon \';\'", @2.last_line);}
| Specifier SEMI {asprintf(&$$,"ExtDef (%d)\n%s\n", @$.first_line, concat_shift($1,$2));}
| Specifier error {syntax_error("semicolon \';\'", @1.last_line);}
| Specifier FunDec CompSt {asprintf(&$$,"ExtDef (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3));} //compst comp with specifier

ExtDecList:
  VarDec {asprintf(&$$,"ExtDecList (%d)\n%s\n", @$.first_line, concat_shift($1));}
| VarDec COMMA ExtDecList {asprintf(&$$,"ExtDecList (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3));}


/* SPECIFIER is related to the type system, in SPL, we have primitive types (int, float and char) and structure type. */
Specifier:
  TYPE {asprintf(&$$,"Specifier (%d)\n%s\n", @$.first_line, concat_shift($1));}
| StructSpecifier {asprintf(&$$,"Specifier (%d)\n%s\n", @$.first_line, concat_shift($1));}

StructSpecifier:
  STRUCT ID LC DefList RC {asprintf(&$$,"StructSpecifier (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3,$4,$5));}
| STRUCT ID LC DefList error {syntax_error("closing curly brace \'}\'",@4.last_line);}
| STRUCT ID {asprintf(&$$,"StructSpecifier (%d)\n%s\n", @$.first_line, concat_shift($1,$2));}


/* DECLARATOR defines the variable and function declaration.
 * Note that the array type is specified by the declarator. */
VarDec:
  ID {asprintf(&$$,"VarDec (%d)\n%s\n", @$.first_line, concat_shift($1));}
| VarDec LB INT RB {asprintf(&$$,"VarDec (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3,$4));}
| VarDec LB INT error {syntax_error("closing bracket \']\'",@3.last_line);}
| VarDec INT RB {syntax_error("closing bracket \'[\'",@3.last_line);}

FunDec:
  ID LP VarList RP {asprintf(&$$,"FunDec (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3,$4));}
| ID LP VarList error {syntax_error("closing parenthesis \')\'",@3.last_line);}
| ID LP RP {asprintf(&$$,"FunDec (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3));}
| ID LP error {syntax_error("closing parenthesis \')\'",@2.last_line);}

VarList:
  ParamDec COMMA VarList {asprintf(&$$,"VarList (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3));}
| ParamDec {asprintf(&$$,"VarList (%d)\n%s\n", @$.first_line, concat_shift($1));}

ParamDec:
  Specifier VarDec {asprintf(&$$,"ParamDec (%d)\n%s\n", @$.first_line, concat_shift($1,$2));}


/* STATEMENT specifies several program structures, such as branching structure or loop structure.
 * They are mostly enclosed by curly braces, or end with a semicolon. */
CompSt: /*Because DefList and StmtList isn't empty, we should list all possible cases in the productions*/
  LC DefList StmtList RC {asprintf(&$$,"CompSt (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3,$4));}
| LC DefList StmtList error {syntax_error("closing curly brace \'}\'",@3.last_line);}
| LC DefList RC {asprintf(&$$,"CompSt (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3));}
| LC DefList error {syntax_error("closing curly brace \'}\'",@2.last_line);}
| LC StmtList RC {asprintf(&$$,"CompSt (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3));}
| LC StmtList error {syntax_error("closing curly brace \'}\'",@2.last_line);}
/*The two error cases below indicate that declaration must before definition*/
| LC DefList StmtList DefList error {syntax_error("specifier",@3.first_line);}
| LC StmtList DefList error {syntax_error("specifier",@2.first_line);}

StmtList: /*To prevent shift/reduce conflict, replace StmtList-->%empty with StmtList-->Stmt*/
  Stmt {asprintf(&$$,"StmtList (%d)\n%s\n", @$.first_line, concat_shift($1));}
| Stmt StmtList {asprintf(&$$,"StmtList (%d)\n%s\n", @$.first_line, concat_shift($1,$2));}

Stmt:
  Exp SEMI {asprintf(&$$,"Stmt (%d)\n%s\n", @$.first_line, concat_shift($1,$2));}
| Exp error {syntax_error("semicolon \';\'",@1.last_line);}
| CompSt {asprintf(&$$,"Stmt (%d)\n%s\n", @$.first_line, concat_shift($1));}
| RETURN Exp SEMI {asprintf(&$$,"Stmt (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3));}
| RETURN Exp error {syntax_error("semicolon \';\'",@2.last_line);}
| RETURN error SEMI /* e.g. return @; only report lexical error */
| IF LP Exp RP Stmt %prec LOWER_ELSE {asprintf(&$$,"Stmt (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3,$4,$5));}
| IF LP Exp RP Stmt ELSE Stmt {asprintf(&$$,"Stmt (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3,$4,$5,$6,$7));}
| IF LP Exp error Stmt {syntax_error("closing parenthesis \')\'",@3.last_line);}
| WHILE LP Exp RP Stmt {asprintf(&$$,"Stmt (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3,$4,$5));}
| WHILE LP Exp error Stmt {syntax_error("closing parenthesis \')\'",@3.last_line);}
| FOR LP Exp SEMI Exp SEMI Exp RP Stmt {asprintf(&$$,"Stmt (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3,$4,$5,$6,$7,$8,$9));}
/*the two production below is about Macro*/
| IFDEF Stmt ENDIF {asprintf(&$$,"Stmt (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3));}
| IFDEF MACRO Stmt MACROELSE Stmt ENDIF {asprintf(&$$,"Stmt (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3,$4,$5,$6));}


/* LOCAL DEFINITION includes the declaration and assignment of local variables. */
DefList: /*To prevent shift/reduce conflict, replace DefList-->%empty with DefList-->Def*/
  Def {asprintf(&$$,"DefList (%d)\n%s\n", @$.first_line, concat_shift($1));}
| Def DefList {asprintf(&$$,"DefList (%d)\n%s\n", @$.first_line, concat_shift($1,$2));}

Def:
  Specifier DecList SEMI {asprintf(&$$,"Def (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3));}
| Specifier DecList error {syntax_error("semicolon \';\'",@2.last_line);} //assign with typelist one by one

DecList:
  Dec {asprintf(&$$,"DecList (%d)\n%s\n", @$.first_line, concat_shift($1));}
| Dec COMMA DecList {asprintf(&$$,"DecList (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3));}

Dec:
  VarDec {asprintf(&$$,"Dec (%d)\n%s\n", @$.first_line, concat_shift($1));}
| VarDec ASSIGN Exp {asprintf(&$$,"Dec (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3));} //assign exp type
| VarDec ASSIGN error /* e.g. int a = $, only report lexical error */


/* EXPRESSION can be a single constant, or operations on variables.
 * Note that these operators have their precedence and associativity, as shown in Table 2 in phase1-guide.pdf. */
Exp:
  Exp ASSIGN Exp {asprintf(&$$,"Exp (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3));}
| Exp AND Exp {asprintf(&$$,"Exp (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3));}
| Exp OR Exp {asprintf(&$$,"Exp (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3));}
| Exp LT Exp {asprintf(&$$,"Exp (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3));}
| Exp LE Exp {asprintf(&$$,"Exp (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3));}
| Exp GT Exp {asprintf(&$$,"Exp (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3));}
| Exp GE Exp {asprintf(&$$,"Exp (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3));}
| Exp NE Exp {asprintf(&$$,"Exp (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3));}
| Exp EQ Exp {asprintf(&$$,"Exp (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3));}
| Exp PLUS Exp {asprintf(&$$,"Exp (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3));}
| Exp MINUS Exp {asprintf(&$$,"Exp (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3));}
| Exp MUL Exp {asprintf(&$$,"Exp (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3));}
| Exp DIV Exp {asprintf(&$$,"Exp (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3));}

| Exp PLUS error {syntax_error("Exp after +",@3.last_line);}
| Exp MINUS error {syntax_error("Exp after -",@3.last_line);}
| Exp MUL error {syntax_error("Exp after *",@3.last_line);}
| Exp DIV error {syntax_error("Exp after /",@3.last_line);}

| LP Exp RP {asprintf(&$$,"Exp (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3));}
| LP Exp error {syntax_error("closing parenthesis \')\'",@2.last_line);}
| MINUS Exp {asprintf(&$$,"Exp (%d)\n%s\n", @$.first_line, concat_shift($1,$2));}
| NOT Exp {asprintf(&$$,"Exp (%d)\n%s\n", @$.first_line, concat_shift($1,$2));}
| ID LP Args RP {asprintf(&$$,"Exp (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3,$4));}
| ID LP Args error {syntax_error("closing parenthesis \')\'",@3.last_line);}
| ID LP RP {asprintf(&$$,"Exp (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3));}
| ID LP error {syntax_error("closing parenthesis \')\'",@2.last_line);}
| Exp LB Exp RB {asprintf(&$$,"Exp (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3,$4));}
| Exp LB Exp error {syntax_error("closing bracket \']\'",@3.last_line);}
| Exp DOT ID {asprintf(&$$,"Exp (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3));}
| ID {;}
| INT {&$$="int";}
| FLOAT {&$$="float";}
| CHAR {&$$="char";}
| STRING {&$$="string";}

Args:
  Exp COMMA Args {asprintf(&$$,"Args (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3));}
| Exp {asprintf(&$$,"Args (%d)\n%s\n", @$.first_line, concat_shift($1));}

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
