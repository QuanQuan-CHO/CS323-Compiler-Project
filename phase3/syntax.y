%{
    using namespace std;

    #define YYSTYPE string //Define the type of `yylval`
    
    #include <string>
    #include "lex.yy.c" //This line MUST AFTER `#define YYSTYPE string`

    void yyerror(const char*){}
%}

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
  ExtDefList {}

ExtDefList:
  %empty {}
| ExtDef ExtDefList {}

ExtDef:
  Specifier ExtDecList SEMI {}
| Specifier SEMI {}
| Specifier FunDec CompSt {}

ExtDecList:
  VarDec {}
| VarDec COMMA ExtDecList {}


/* SPECIFIER is related to the type system, in SPL, we have primitive types (int, float and char) and structure type. */
Specifier:
  TYPE {}
| StructSpecifier {}

StructSpecifier:
  STRUCT ID LC DefList RC {}
| STRUCT ID {}


/* DECLARATOR defines the variable and function declaration.
 * Note that the array type is specified by the declarator. */
VarDec:
  ID {}
| VarDec LB INT RB {}
| VarDec INT RB {}

FunDec:
  ID LP VarList RP {}
| ID LP RP {}
| ID LP error {}

VarList:
  ParamDec COMMA VarList {}
| ParamDec {}

ParamDec:
  Specifier VarDec {}


/* STATEMENT specifies several program structures, such as branching structure or loop structure.
 * They are mostly enclosed by curly braces, or end with a semicolon. */
CompSt: /*Because DefList and StmtList isn't empty, we should list all possible cases in the productions*/
  LC DefList StmtList RC {}
| LC DefList RC {}
| LC StmtList RC {}

StmtList: /*To prevent shift/reduce conflict, replace StmtList-->%empty with StmtList-->Stmt*/
  Stmt {}
| Stmt StmtList {}

Stmt:
  Exp SEMI {}
| CompSt {}
| RETURN Exp SEMI {}
| IF LP Exp RP Stmt %prec LOWER_ELSE {}
| IF LP Exp RP Stmt ELSE Stmt {}


/* LOCAL DEFINITION includes the declaration and assignment of local variables. */
DefList: /*To prevent shift/reduce conflict, replace DefList-->%empty with DefList-->Def*/
  Def {}
| Def DefList {}

Def:
  Specifier DecList SEMI {}

DecList:
  Dec {}
| Dec COMMA DecList {}

Dec:
  VarDec {}
| VarDec ASSIGN Exp {}


/* EXPRESSION can be a single constant, or operations on variables.
 * Note that these operators have their precedence and associativity, as shown in Table 2 in phase1-guide.pdf. */
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
| LP Exp RP {}
| MINUS Exp {}
| NOT Exp {}
| ID LP Args RP {}
| ID LP RP {}
| Exp LB Exp RB {}
| Exp DOT ID {}
| ID {}
| INT {}
| FLOAT {}
| CHAR {}

Args:
  Exp COMMA Args {}
| Exp {}

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
