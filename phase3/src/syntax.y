%{
    using namespace std;

    #define YYSTYPE node* //Define the type of `yylval`
    
    #include <fstream>
    #include "translate.cpp" //This line MUST BEFORE `#include "lex.yy.c"`
    #include "lex.yy.c" //This line MUST AFTER `#define YYSTYPE node*`

    node* root; //root of syntax tree

    //convert `Exp1 [+-*/]= Exp2` to `Exp1 = Exp1 [+-*/] Exp2`
    node* convert_assign(node* Exp1, node* Exp2, string _operator){
        node* op = new node(_operator); //`operator` is an internal keyword in C++
        node* res = new node("Exp",vector{Exp1,op,Exp2});
        node* assign = new node("ASSIGN");
        return new node("Exp",vector{Exp1,assign,res});
    }

    //convert `Exp[++|--]` to `Exp = Exp [+-] 1`
    node* convert_self_assign(node* Exp, string _operator){ //`operator` is an internal keyword in C++
        node* one = new node("Exp", vector{new node("INT", "#1")});
        return convert_assign(Exp, one, _operator);
    }
    
    void yyerror(const char*){}
%}

%nonassoc LOWER_ELSE
%nonassoc ELSE

%token TYPE INT CHAR FLOAT STRUCT ID
%token IF WHILE FOR RETURN /*control flow word*/
%token COMMA

%right ASSIGN
%right PLUS_ASSIGN MINUS_ASSIGN MUL_ASSIGN DIV_ASSIGN /* += -= *= /= */
%right SELF_PLUS SELF_MINUS /* ++ -- */
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
  ExtDefList {root=$1;}

ExtDefList:
  %empty {$$=new node("ExtDefList");}
| ExtDef ExtDefList {$$=new node("ExtDefList",vector{$1,$2});}

ExtDef:
  Specifier ExtDecList SEMI {$$=new node("ExtDef",vector{$1,$2,$3});}
| Specifier SEMI {$$=new node("ExtDef",vector{$1,$2});}
| Specifier FunDec CompSt {$$=new node("ExtDef",vector{$1,$2,$3});}

ExtDecList:
  VarDec {$$=new node("ExtDecList",vector{$1});}
| VarDec COMMA ExtDecList {$$=new node("ExtDecList",vector{$1,$2,$3});}


/* SPECIFIER is related to the type system, in SPL, we have primitive types (int, float and char) and structure type. */
Specifier:
  TYPE {$$=new node("Specifier",vector{$1});}
| StructSpecifier {$$=new node("Specifier",vector{$1});}

StructSpecifier:
  STRUCT ID LC DefList RC {$$=new node("StructSpecifier",vector{$1,$2,$3,$4,$5});}
| STRUCT ID {$$=new node("StructSpecifier",vector{$1,$2});}


/* DECLARATOR defines the variable and function declaration.
 * Note that the array type is specified by the declarator. */
VarDec:
  ID {$$=new node("VarDec",vector{$1});}
| VarDec LB INT RB {$$=new node("VarDec",vector{$1,$2,$3,$4});}

FunDec:
  ID LP VarList RP {$$=new node("FunDec",vector{$1,$2,$3,$4});}
| ID LP RP {$$=new node("FunDec",vector{$1,$2,$3});}

VarList:
  ParamDec COMMA VarList {$$=new node("VarList",vector{$1,$2,$3});}
| ParamDec {$$=new node("VarList",vector{$1});}

ParamDec:
  Specifier VarDec {$$=new node("ParamDec",vector{$1,$2});}


/* STATEMENT specifies several program structures, such as branching structure or loop structure.
 * They are mostly enclosed by curly braces, or end with a semicolon. */
CompSt: /*Because DefList and StmtList isn't empty, we should list all possible cases in the productions*/
  LC DefList StmtList RC {$$=new node("CompSt",vector{$1,$2,$3,$4});}
| LC DefList RC {$$=new node("CompSt",vector{$1,$2,$3});}
| LC StmtList RC {$$=new node("CompSt",vector{$1,$2,$3});}
| LC StmtList DefList StmtList RC {$$=new node("CompSt",vector{$1,$2,$3,$4,$5});}

StmtList: /*To prevent shift/reduce conflict, replace StmtList-->%empty with StmtList-->Stmt*/
  Stmt {$$=new node("StmtList",vector{$1});}
| Stmt StmtList {$$=new node("StmtList",vector{$1,$2});}

Stmt:
  CompSt {$$=new node("Stmt",vector{$1});}
| Exp SEMI {$$=new node("Stmt",vector{$1,$2});}
| RETURN Exp SEMI {$$=new node("Stmt",vector{$1,$2,$3});}
| IF LP Exp RP Stmt %prec LOWER_ELSE {$$=new node("Stmt",vector{$1,$2,$3,$4,$5});}
| IF LP Exp RP Stmt ELSE Stmt {$$=new node("Stmt",vector{$1,$2,$3,$4,$5,$6,$7});}
| WHILE LP Exp RP Stmt {$$=new node("Stmt",vector{$1,$2,$3,$4,$5});}
| FOR LP Def Exp SEMI Exp RP Stmt {$$=new node("Stmt",vector{$1,$2,$3,$4,$5,$6,$7,$8});} //for(...;...;...){...}
| FOR LP Def Exp SEMI RP Stmt {$$=new node("Stmt",vector{$1,$2,$3,$4,$5,$6,$7});}        //for(...;...;){...}
| FOR LP SEMI Exp SEMI Exp RP Stmt {$$=new node("Stmt",vector{$1,$2,$3,$4,$5,$6,$7,$8});}//for(;...;...){...}
| FOR LP SEMI Exp SEMI RP Stmt {$$=new node("Stmt",vector{$1,$2,$3,$4,$5,$6,$7});}       //for(;...;){...}

/* LOCAL DEFINITION includes the declaration and assignment of local variables. */
DefList: /*To prevent shift/reduce conflict, replace DefList-->%empty with DefList-->Def*/
  Def {$$=new node("DefList",vector{$1});}
| Def DefList {$$=new node("DefList",vector{$1,$2});}

Def:
  Specifier DecList SEMI {$$=new node("Def",vector{$1,$2,$3});}

DecList:
  Dec {$$=new node("DecList",vector{$1});}
| Dec COMMA DecList {$$=new node("DecList",vector{$1,$2,$3});}

Dec:
  VarDec {$$=new node("Dec",vector{$1});}
| VarDec ASSIGN Exp {$$=new node("Dec",vector{$1,$2,$3});}


/* EXPRESSION can be a single constant, or operations on variables.
 * Note that these operators have their precedence and associativity, as shown in Table 2 in phase1-guide.pdf. */
Exp:
  Exp ASSIGN Exp {$$=new node("Exp",vector{$1,$2,$3});}
| Exp PLUS_ASSIGN Exp {$$=convert_assign($1,$3,"PLUS");}  //convert `Exp1 += Exp2` to `Exp1 = Exp1 + Exp2`
| Exp MINUS_ASSIGN Exp {$$=convert_assign($1,$3,"MINUS");}//convert `Exp1 -= Exp2` to `Exp1 = Exp1 - Exp2`
| Exp MUL_ASSIGN Exp {$$=convert_assign($1,$3,"MUL");}    //convert `Exp1 *= Exp2` to `Exp1 = Exp1 * Exp2`
| Exp DIV_ASSIGN Exp {$$=convert_assign($1,$3,"DIV");}    //convert `Exp1 /= Exp2` to `Exp1 = Exp1 / Exp2`
| Exp SELF_PLUS {$$=convert_self_assign($1,"PLUS");}      //convert `Exp++` to `Exp = Exp + 1`
| Exp SELF_MINUS {$$=convert_self_assign($1,"MINUS");}    //convert `Exp--` to `Exp = Exp - 1`
| Exp AND Exp {$$=new node("Exp",vector{$1,$2,$3});}
| Exp OR Exp {$$=new node("Exp",vector{$1,$2,$3});}
| Exp LT Exp {$$=new node("Exp",vector{$1,$2,$3});}
| Exp LE Exp {$$=new node("Exp",vector{$1,$2,$3});}
| Exp GT Exp {$$=new node("Exp",vector{$1,$2,$3});}
| Exp GE Exp {$$=new node("Exp",vector{$1,$2,$3});}
| Exp NE Exp {$$=new node("Exp",vector{$1,$2,$3});}
| Exp EQ Exp {$$=new node("Exp",vector{$1,$2,$3});}
| Exp PLUS Exp {$$=new node("Exp",vector{$1,$2,$3});}
| Exp MINUS Exp {$$=new node("Exp",vector{$1,$2,$3});}
| Exp MUL Exp {$$=new node("Exp",vector{$1,$2,$3});}
| Exp DIV Exp {$$=new node("Exp",vector{$1,$2,$3});}
| LP Exp RP {$$=new node("Exp",vector{$1,$2,$3});}
| MINUS Exp {$$=new node("Exp",vector{$1,$2});}
| NOT Exp {$$=new node("Exp",vector{$1,$2});}
| ID LP Args RP {$$=new node("Exp",vector{$1,$2,$3,$4});}
| ID LP RP {$$=new node("Exp",vector{$1,$2,$3});}
| Exp LB Exp RB {$$=new node("Exp",vector{$1,$2,$3,$4});}
| Exp DOT ID {$$=new node("Exp",vector{$1,$2,$3});}
| ID {$$=new node("Exp",vector{$1});}
| INT {$$=new node("Exp",vector{$1});}
| FLOAT {$$=new node("Exp",vector{$1});}
| CHAR {$$=new node("Exp",vector{$1});}

Args:
  Exp COMMA Args {$$=new node("Args",vector{$1,$2,$3});}
| Exp {$$=new node("Args",vector{$1});}

%%

int main(int argc, char** argv){
    if(argc < 2){
        fprintf(stderr, "Usage: %s <file_path>\n", argv[0]);
        return 1;
    }else if(argc == 2){
        if(!(yyin=fopen(argv[1], "r"))){
            perror(argv[1]);
            return 1;
        }
        yyparse();

        //write .ir file
        string spl_path = argv[1];
        string ir = translate_ExtDefList(root);
        string ir_path = spl_path.substr(0, spl_path.rfind('.')) + ".ir";
        ofstream out_stream(ir_path);
        out_stream << ir;
        out_stream.close();
        return 0;
    }else{
        fputs("Too many arguments! Expected: 2.\n", stderr);
        return 1;
    }
}
