%{
    using namespace std;

    #define YYSTYPE char* //Define the type of `yylval`

    #include "lex.yy.c"

    extern int yylineno;
    bool has_error=false; //Has lexical or syntax error
    void yyerror(const char*);
    
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

    //TODO: Optimize by macro
%}
%locations
%define parse.error verbose

%nonassoc LOWER_ELSE
%nonassoc ELSE

%token TYPE INT CHAR FLOAT STRUCT ID
%token IF WHILE RETURN /*control flow word*/
%token COMMA

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

ExtDefList:
  %empty {$$=strdup("");}
| ExtDef ExtDefList {asprintf(&$$,"ExtDefList (%d)\n%s\n", @$.first_line, concat_shift($1,$2));}

ExtDef:
  Specifier ExtDecList SEMI {asprintf(&$$,"ExtDef (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3));}
| Specifier ExtDecList error {syntax_error("semicolon \';\'",@$.first_line);}
| Specifier SEMI {asprintf(&$$,"ExtDef (%d)\n%s\n", @$.first_line, concat_shift($1,$2));}
| Specifier error {syntax_error("semicolon \';\'",@$.first_line);}
| Specifier FunDec CompSt {asprintf(&$$,"ExtDef (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3));}

ExtDecList:
  VarDec {asprintf(&$$,"ExtDecList (%d)\n%s\n", @$.first_line, concat_shift($1));}
| VarDec COMMA ExtDecList {asprintf(&$$,"ExtDecList (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3));}


/* SPECIFIER is related to the type system, in SPL, we have primitive types (int, float and char) and structure type. */
Specifier:
  TYPE {asprintf(&$$,"Specifier (%d)\n%s\n", @$.first_line, concat_shift($1));}
| StructSpecifier {asprintf(&$$,"Specifier (%d)\n%s\n", @$.first_line, concat_shift($1));}

StructSpecifier:
  STRUCT ID LC DefList RC {asprintf(&$$,"StructSpecifier (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3,$4,$5));}
| STRUCT ID LC DefList error {syntax_error("closing curly brace \'}\'",@$.first_line);}
| STRUCT ID {asprintf(&$$,"StructSpecifier (%d)\n%s\n", @$.first_line, concat_shift($1,$2));}


/* DECLARATOR defines the variable and function declaration.
 * Note that the array type is specified by the declarator. */
VarDec:
  ID {asprintf(&$$,"VarDec (%d)\n%s\n", @$.first_line, concat_shift($1));}
| VarDec LB INT RB {asprintf(&$$,"VarDec (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3,$4));}
| VarDec LB INT error {syntax_error("closing bracket \']\'",@$.first_line);}

FunDec:
  ID LP VarList RP {asprintf(&$$,"FunDec (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3,$4));}
| ID LP VarList error {syntax_error("closing parenthesis \')\'",@$.first_line);}
| ID LP RP {asprintf(&$$,"FunDec (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3));}
| ID LP error {syntax_error("closing parenthesis \')\'",@$.first_line);}

VarList:
  ParamDec COMMA VarList {asprintf(&$$,"VarList (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3));}
| ParamDec {asprintf(&$$,"VarList (%d)\n%s\n", @$.first_line, concat_shift($1));}

ParamDec:
  Specifier VarDec {asprintf(&$$,"ParamDec (%d)\n%s\n", @$.first_line, concat_shift($1,$2));}


/* STATEMENT specifies several program structures, such as branching structure or loop structure.
 * They are mostly enclosed by curly braces, or end with a semicolon. */
CompSt:
  LC DefList StmtList RC {asprintf(&$$,"CompSt (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3,$4));}
| LC DefList StmtList error {syntax_error("closing curly brace \'}\'",@$.first_line);}

StmtList:
  %empty {$$=strdup("");}
| Stmt StmtList {asprintf(&$$,"StmtList (%d)\n%s\n", @$.first_line, concat_shift($1,$2));}

Stmt:
  Exp SEMI {asprintf(&$$,"Stmt (%d)\n%s\n", @$.first_line, concat_shift($1,$2));}
| Exp error {syntax_error("semicolon \';\'",@$.first_line);}
| CompSt {asprintf(&$$,"Stmt (%d)\n%s\n", @$.first_line, concat_shift($1));}
| RETURN Exp SEMI {asprintf(&$$,"Stmt (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3));}
| RETURN Exp error {syntax_error("semicolon \';\'",@$.first_line);}
| RETURN error SEMI /* e.g. return @; only report lexical error */
| IF LP Exp RP Stmt %prec LOWER_ELSE {asprintf(&$$,"Stmt (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3,$4,$5));}
| IF LP Exp RP Stmt ELSE Stmt {asprintf(&$$,"Stmt (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3,$4,$5,$6,$7));}
| IF LP Exp error Stmt {syntax_error("closing parenthesis \')\'",@$.first_line);}
| WHILE LP Exp RP Stmt {asprintf(&$$,"Stmt (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3,$4,$5));}
| WHILE LP Exp error Stmt {syntax_error("closing parenthesis \')\'",@$.first_line);}


/* LOCAL DEFINITION includes the declaration and assignment of local variables. */
DefList:
  %empty {$$=strdup("");}
| Def DefList {asprintf(&$$,"DefList (%d)\n%s\n", @$.first_line, concat_shift($1,$2));}

Def:
  Specifier DecList SEMI {asprintf(&$$,"Def (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3));}
| Specifier DecList error {syntax_error("semicolon \';\'",@$.first_line);}

DecList:
  Dec {asprintf(&$$,"DecList (%d)\n%s\n", @$.first_line, concat_shift($1));}
| Dec COMMA DecList {asprintf(&$$,"DecList (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3));}

Dec:
  VarDec {asprintf(&$$,"Dec (%d)\n%s\n", @$.first_line, concat_shift($1));}
| VarDec ASSIGN Exp {asprintf(&$$,"Dec (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3));}
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
| LP Exp RP {asprintf(&$$,"Exp (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3));}
| LP Exp error {syntax_error("closing parenthesis \')\'",@$.first_line);}
| MINUS Exp {asprintf(&$$,"Exp (%d)\n%s\n", @$.first_line, concat_shift($1,$2));}
| NOT Exp {asprintf(&$$,"Exp (%d)\n%s\n", @$.first_line, concat_shift($1,$2));}
| ID LP Args RP {asprintf(&$$,"Exp (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3,$4));}
| ID LP Args error {syntax_error("closing parenthesis \')\'",@$.first_line);}
| ID LP RP {asprintf(&$$,"Exp (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3));}
| ID LP error {syntax_error("closing parenthesis \')\'",@$.first_line);}
| Exp LB Exp RB {asprintf(&$$,"Exp (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3,$4));}
| Exp LB Exp error {syntax_error("closing bracket \']\'",@$.first_line);}
| Exp DOT ID {asprintf(&$$,"Exp (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3));}
| ID {asprintf(&$$,"Exp (%d)\n%s\n", @$.first_line, concat_shift($1));}
| INT {asprintf(&$$,"Exp (%d)\n%s\n", @$.first_line, concat_shift($1));}
| FLOAT {asprintf(&$$,"Exp (%d)\n%s\n", @$.first_line, concat_shift($1));}
| CHAR {asprintf(&$$,"Exp (%d)\n%s\n", @$.first_line, concat_shift($1));}

Args:
  Exp COMMA Args {asprintf(&$$,"Args (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3));}
| Exp {asprintf(&$$,"Args (%d)\n%s\n", @$.first_line, concat_shift($1));}

%%

void yyerror(const char* s) {}

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
