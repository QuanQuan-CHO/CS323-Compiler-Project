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
  ExtDefList {chedef($1);}
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
  %empty {$$=new rec(noact);}
| ExtDef ExtDefList {$2->link(1,$1);$$=$2;}

ExtDef:
  Specifier ExtDecList SEMI {def($1,$2,imap);}
  //将所有的speci之后的val设为specifier
| Specifier ExtDecList error {syntax_error("semicolon \';\'", @2.last_line);}
| Specifier SEMI {$$=$1;}
| Specifier error {syntax_error("semicolon \';\'", @1.last_line);}
| Specifier FunDec CompSt {$2->val=$1;checkreturn($2,$3,imap);}
//检查Compst中的所有val并且与spe对照

ExtDecList:
  VarDec {$$=new rec(noact);$$->link(1,$1);}
| VarDec COMMA ExtDecList {$3->link(1,$1);$$=$3;}

Specifier:
  TYPE {$$=$1;}
| StructSpecifier {$$=$1;}

StructSpecifier:
  STRUCT ID LC DefList RC {$2->line_num=@2.last_line;$2->t=structvar;$1->val=$4;def($1,$2,imap);$$=$2;}
  //apple 的类型为structvar val的名为struct val为一个连接结点，连接结点的recs为全部的成员变量
  //结构体的val表示它内部的定义，t表示它是结构体
| STRUCT ID LC DefList error {syntax_error("closing curly brace \'}\'",@4.last_line);}
| STRUCT ID {$2->line_num=@2.last_line;$2->t=structvar;def($1,$2,imap);$$=$2;}

VarDec:
  ID {$1->line_num=@1.last_line;$$=$1;}
| VarDec LB INT RB {$1->t=arr; $1->val=new rec(noact); buildarr($1->val,$3);$$=$1;}
//数组的val表示它的类型，t表示它是数组，vec的大小表示它的长度
//变量的val表示值，t表示它的类型，定义后val值应为相应类型的对应复制
//fun的val表示返回值，queue表示所需参数
| VarDec LB INT error {syntax_error("closing bracket \']\'",@3.last_line);}
| VarDec INT RB {syntax_error("closing bracket \'[\'",@3.last_line);}
// | VarDec LB error RB {} 

FunDec:
  ID LP VarList RP {$1->t=fun;$1->line_num=@1.last_line;$1->recs=$3->recs;def(nullptr,$2,imap);$$=$1;}
| ID LP VarList error {syntax_error("closing parenthesis \')\'",@3.last_line);}
| ID LP RP {$1->t=fun;$1->line_num=@1.last_line;def(nullptr,$2,imap);$$=$1;}
| ID LP error {syntax_error("closing parenthesis \')\'",@2.last_line);}

VarList:
  ParamDec COMMA VarList {$3->link(1,$1);$$=$3;}
| ParamDec {$$=new rec(noact);$$->link(1,$1);}

ParamDec:
  Specifier VarDec {def($1,$2,imap);$$=$2;}
   //遍历list的queue，改变其t，并且在map中记录<name,rec>

CompSt:
  LC DefList StmtList RC {
    // map* nmap=new map();nmap->outmap=&imap;imap=*nmap;
  $$=$3;}
   //所有def stmt的val除了ruturn语句均为空
| LC DefList RC {}
| LC DefList error {syntax_error("closing curly brace \'}\'",@2.last_line);}
| LC StmtList RC {$$=$2;}
| LC DefList StmtList error {syntax_error("closing curly brace \'}\'",@3.last_line);}
| LC DefList StmtList DefList error {syntax_error("specifier",@3.first_line);}

StmtList:
  Stmt {$$=new rec(noact);$$->link(1,chedef($1));}
| Stmt StmtList {$2->link(1,chedef($1));$$=$2;}

Stmt:
  Exp SEMI {$$=$1;}
  //该节点val为null
  //assign和noact 的val均为nullptr
| Exp error {syntax_error("semicolon \';\'",@1.last_line);}
| CompSt {$$=new rec(noact);$$->link(1,$1);}
| RETURN Exp SEMI {$$=$2;}
//此节点得到的是exp的val
| RETURN Exp error {syntax_error("semicolon \';\'",@2.last_line);}
| RETURN error SEMI {}
| IF LP Exp RP Stmt %prec LOWER_ELSE {$$=new rec(noact);$$->link(2,$3,$5);}
| IF LP Exp RP Stmt ELSE Stmt {$$=new rec(noact);$$->link(3,$3,$5,$7);}
| IF LP Exp error Stmt {syntax_error("closing parenthesis \')\'",@3.last_line);}
| WHILE LP Exp RP Stmt {$$=new rec(noact);$$->link(2,$3,$5);}
| WHILE LP Exp error Stmt {syntax_error("closing parenthesis \')\'",@3.last_line);}
| FOR LP Exp SEMI Exp SEMI Exp RP Stmt {$$=new rec(noact);$$->link(4,$3,$5,$7,$9);}
| IFDEF Stmt ENDIF {}
| IFDEF MACRO Stmt MACROELSE Stmt ENDIF {}

DefList:
  Def {$$=new rec(noact);$$->link(1,$1);}
| Def DefList {$2->link(1,$1);$$=$2;}

Def:
  Specifier DecList SEMI {def($1,$2,imap);$$=$2;} //def muti var
  //遍历list的queue，改变其t，并且在map中记录<name,rec>
| Specifier DecList error {syntax_error("semicolon \';\'",@2.last_line);}

DecList:
  Dec {$$=new rec(noact);$$->link(1,$1);}
| Dec COMMA DecList {$3->link(1,$1); $$=$3;}

Dec:
  VarDec {$$=$1;}
| VarDec ASSIGN Exp {$$=new rec(imap,$1,$3,usbiop);}
//检查两边变量
//将queue中第一个变量的val设为exp的val
//该节点val返回为赋完值的vardec
| VarDec ASSIGN error {}

Exp:
  Exp ASSIGN Exp {$$=new rec($1,$3,usbiop);}
  //var 需通过val检测，这个val的t将表示它的类型，val将指向它所存的值
  //检查两边变量，尝试另var val的val指向EXP
| Exp AND Exp {$$=new rec($1,$3,usbiop);}
| Exp OR Exp {$$=new rec($1,$3,usbiop);}
| Exp LT Exp {$$=new rec($1,$3,usbiop);}
| Exp LE Exp {$$=new rec($1,$3,usbiop);}
| Exp GT Exp {$$=new rec($1,$3,usbiop);}
| Exp GE Exp {$$=new rec($1,$3,usbiop);}
| Exp NE Exp {$$=new rec($1,$3,usbiop);}
| Exp EQ Exp {$$=new rec($1,$3,usbiop);}
| Exp PLUS Exp {$$=new rec($1,$3,usbiop);}
| Exp MINUS Exp {$$=new rec($1,$3,usbiop);}
| Exp MUL Exp {$$=new rec($1,$3,usbiop);}
| Exp DIV Exp {$$=new rec($1,$3,usbiop);}
//使用双目运算符，检查queue第一二个变量是否为数字且相同类型
//该节点val设为其第一个变量类型的复制

| Exp PLUS error {syntax_error("Exp after +",@3.last_line);}
| Exp MINUS error {syntax_error("Exp after -",@3.last_line);}
| Exp MUL error {syntax_error("Exp after *",@3.last_line);}
| Exp DIV error {syntax_error("Exp after /",@3.last_line);}

| LP Exp RP {$$=$1;}
| LP Exp error {syntax_error("closing parenthesis \')\'",@2.last_line);}
| MINUS Exp {$$=new rec($2,new rec(),usbiop);}
| NOT Exp {$$=new rec($2,new rec(),usbiop);}
//使用单目操作符，检查queue第一个变量是否为数字类型
//该节点val设为其第一个变量类型的复制
| ID LP Args RP {$1->line_num=@1.last_line;$$=new rec($1,$3,usfun);}
//使用函数，queue中第一个检查ID的fun name在字典中的对应值，对应值应能找到并且t为fun
//获取queue第二个变量，在第二个变量的queue中查每个参数对应的类型，应存在并且与对应值中的args中queue每个个体的类型依次对应，数目不对立即输出结果，类型错误继续检测
//该节点的val应设为为fun的val
//检测存在为通用方法
| ID LP Args error {$1->line_num=@1.last_line;syntax_error("closing parenthesis \')\'",@3.last_line);}
| ID LP RP {$1->line_num=@1.last_line;$$=new rec($1,new rec(),usfun);}
//使用函数，queue中第一个检查ID的fun name在字典中的对应值，对应值应能找到并且fun应为true
//尝试获取queue第二个变量，如果没有获得对应值的queue应也为空
//该节点的val应设为为fun的return
| ID LP error {syntax_error("closing parenthesis \')\'",@2.last_line);}
| Exp LB Exp RB {$$=new rec(usarr,$1,$3);}
//使用数组，用queue第一个变量检查是否存在，是否为数组，第二个变量（EXP）的t应为intval或var，
//若为var，查询是否存在，以及其val是否指向一个intval
//找到之后找在它的queque中名字与intval名相同的变量，若没有，则创建一个t为该变量的类型的rec，名为intval相同的rec存入
//该节点val应为第一个变量中名相同的指针
| Exp LB Exp error {syntax_error("closing bracket \']\'",@3.last_line);}
| Exp DOT ID {$3->line_num=@3.last_line;$$=new rec(usstruct,$1,$3);} 
//使用结构体，queue第一个变量名字查找，是否t为structvar，找到之后找在它的struct，struct的含义为一个list，在该list的queue中找名字与ID名相同的变量
//如果通过，该点的val需要设为ID名相同的变量的指针
| ID {$1->line_num=@1.last_line;$$=$1;} //ID的名为变量名称
| INT {$1->line_num=@1.last_line;$$=$1;$$->val=$1;}
| FLOAT {$1->line_num=@1.last_line;$$=$1;$$->val=$1;}
| CHAR {$1->line_num=@1.last_line;$$=$1;$$->val=$1;}
| STRING {$1->line_num=@1.last_line;$$=$1;$$->val=$1;} //该节点的val为其自己

Args:
  Exp COMMA Args {$3->link(1,$1); $$=$3;}
| Exp {$$=new rec(noact);$$->link(1,$1);} //queue存并列元素

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