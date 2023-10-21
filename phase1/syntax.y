%define parse.error verbose
%locations
%{
    #include "lex.yy.c"
    void yyerror(const char*);
    char* get_str2(const char* name, const char* str1);
    char* get_str3(const char* name, const char* str1,const char* str2);
    char* get_str4(const char* name, const char* str1, const char* str2, const char* str3);
    char* get_str5(const char* name, const char* str1,const char* str2,const char* str3,const char* str4);
    char* get_str6(const char* name, const char* str1,const char* str2,const char* str3,const char* str4,const char* str5);
    char* get_name_posi(const char* arg, int posi);
    char* get_name_val(const char* arg, const char* val);

%}
%token STRUCT IF ELSE WHILE RETURN SEMI COMMA
%token EQ LE GE NE ASSIGN NOT LT GT PLUS MINUS MUL DIV AND OR
%token LP RP LB RB LC RC INT FLOAT CHAR ID TYPE DOT
%left MUL DIV AND OR LT LE GT GE NE EQ PLUS MINUS ASSIGN DOT
%right LB NOT
%%

/* high-level definition */
/* global variable declarations and function definitions */
output: Program{
char* name1=get_name_posi("Program",@1.first_line);
char* str1=get_str2(name1,$1);
printf("%s",str1);
}

Program: ExtDefList { 
char* name1=get_name_posi("ExtDefList",@1.first_line);
char* str1=get_str2(name1,$1);
$$=str1; 
}
ExtDefList: 
    | ExtDef ExtDefList { 
    char* name1=get_name_posi("ExtDef",@1.first_line);
    char* str1=get_str2(name1,$1);
    char* name2=get_name_posi("ExtDecList",@2.first_line);
    char* str2=get_str2(name2,$2);
    $$=get_str2(str1,str2); 
    }
ExtDef: Specifier ExtDecList SEMI { 
    char* name1=get_name_posi("Specifier",@1.first_line);
    char* str1=get_str2(name1,$1);
    char* name2=get_name_posi("ExtDecList",@2.first_line);
    char* str2=get_str2(name2,$2);
    $$=get_str3(str1,str2,$3);  
    }
    | Specifier SEMI { 
    char* name1=get_name_posi("Specifier",@1.first_line);
    char* str1=get_str2(name1,$1);
    $$=get_str2(str1,$2); 
    }
    | Specifier FunDec CompSt { 
    char* name1=get_name_posi("Specifier",@1.first_line);
    char* str1=get_str2(name1,$1);
    char* name2=get_name_posi("FunDec",@2.first_line);
    char* str2=get_str2(name2,$2);
    char* name3=get_name_posi("DefList",@3.first_line);
    char* str3=get_str2(name3,$3);
    $$=get_str3(str1,str2,str3); 
    }
ExtDecList: VarDec
    | VarDec COMMA ExtDecList { 
    char* name1=get_name_posi("VarDec",@1.first_line);
    char* str1=get_str2(name1,$1);
    char* name3=get_name_posi("ExtDecList",@3.first_line);
    char* str3=get_str2(name3,$3);
    $$=get_str3(str1,$2,str3); 
    }

/* specifier */
/* primitive types (int, float and char) and structure type */
Specifier: TYPE { 
    char* name1=get_name_val("TYPE",$1);
    $$=name1; 
    }
    | StructSpecifier { 
    char* name1=get_name_posi("StructSpecifier",@1.first_line);
    char* str1=get_str2(name1,$1);
    $$=str1; 
    }
StructSpecifier: STRUCT ID LC DefList RC { 
    char* name1=get_name_posi("STRUCT",@1.first_line);
    char* str1=get_str2(name1,$1);
    char* name2=get_name_val("ID",$2);
    char* name4=get_name_posi("DefList",@4.first_line);
    char* str4=get_str2(name4,$4);
    $$=get_str5(str1,name2,$3,str4,$5); 
    }
    | STRUCT ID { 
    char* name1=get_name_posi("STRUCT",@1.first_line);
    char* str1=get_str2(name1,$1);
    char* name2=get_name_val("ID",$2);
    $$=get_str2(str1,name2); 
    }

/* declarator */
/* variable and function declaration */
VarDec: ID { printf("ID: %s\n", $1); }
    | VarDec LB INT RB { 
    char* name1=get_name_posi("VarDec",@1.first_line);
    char* str1=get_str2(name1,$1);
    char* name3=get_name_val("INT",$3);
    $$=get_str4(str1,$2,name3,$4);   
    }
FunDec: ID LP VarList RP { 
    char* name1=get_name_val("ID",$1);
    char* name3=get_name_posi("VarList",@3.first_line);
    char* str3=get_str2(name3,$3);
    $$=get_str4(name1,$2,str3,$4);  
    }
    | ID LP RP { 
    char* name1=get_name_val("ID",$1);
    $$=get_str3(name1,$2,$3);  
    }
VarList: ParamDec COMMA VarList { 
    char* name1=get_name_posi("ParamDec",@1.first_line);
    char* str1=get_str2(name1,$1);
    char* name3=get_name_posi("ParamDec",@3.first_line);
    char* str3=get_str2(name3,$3);
    $$=get_str3(str1,$2,str3);  
    }
    | ParamDec { 
    char* name1=get_name_posi("ParamDec",@1.first_line);
    char* str1=get_str2(name1,$1);
    $$=str1;
    }
ParamDec: Specifier VarDec { 
    char* name1=get_name_posi("Specifier",@1.first_line);
    char* str1=get_str2(name1,$1);
    char* name2=get_name_posi("Specifier",@2.first_line);
    char* str2=get_str2(name2,$2);
    $$=get_str2(str1,str2);  
    }

/* statement */
/* specifies several program structures */
CompSt: LC DefList StmtList RC { 
    char* name2=get_name_posi("DefList",@2.first_line);
    char* str2=get_str2(name2,$2);
    char* name3=get_name_posi("StmtList",@3.first_line);
    char* str3=get_str2(name3,$3);
    $$=get_str4($1,str2,str3,$4);  
    }
StmtList:
    | Stmt StmtList { 
    char* name1=get_name_posi("Stmt",@1.first_line);
    char* str1=get_str2(name1,$1);
    char* name2=get_name_posi("StmtList",@2.first_line);
    char* str2=get_str2(name2,$2);
    $$=get_str2(str1,str2); 
    }
    | ifelseStmt StmtList { 
    char* name1=get_name_posi("Stmt",@1.first_line);
    char* str1=get_str2(name1,$1);
    char* name2=get_name_posi("StmtList",@2.first_line);
    char* str2=get_str2(name2,$2);
    $$=get_str2(str1,str2); }
    | ifstmt StmtList { 
    char* name1=get_name_posi("Stmt",@1.first_line);
    char* str1=get_str2(name1,$1);
    char* name2=get_name_posi("StmtList",@2.first_line);
    char* str2=get_str2(name2,$2);
    $$=get_str2(str1,str2); }

Stmt: Exp SEMI { 
    char* name1=get_name_posi("Exp",@1.first_line);
    char* str1=get_str2(name1,$1);
    $$=get_str2(str1,$2);
    }
    | CompSt {
    char* name1=get_name_posi("CompSt",@1.first_line);
    char* str1=get_str2(name1,$1);
    $$=str1;    
    }
    | RETURN Exp SEMI {
    char* name2=get_name_posi("Exp",@2.first_line);
    char* str2=get_str2(name2,$3);
    $$=get_str3($1,str2,$3);
    }
    | WHILE LP Exp RP Stmt {
    char* name3=get_name_posi("Exp",@3.first_line);
    char* str3=get_str2(name3,$3);
    char* name5=get_name_posi("Stmt",@5.first_line);
    char* str5=get_str2(name5,$5);
    $$=get_str5($1,$2,str3,$4,str5);
    }

ifelseStmt: ifstmt elsest
ifstmt: IF LP Exp RP Stmt { 
    char* name3=get_name_posi("Exp",@3.first_line);
    char* str3=get_str2(name3,$3);
    char* name5=get_name_posi("Stmt",@5.first_line);
    char* str5=get_str2(name5,$5);
    $$=get_str5($1,$2,str3,$4,str5); 
    }
elsest: ELSE Stmt {
    char* name2=get_name_posi("Stmt",@2.first_line);
    char* str2=get_str2(name2,$2);
    $$=get_str2($1,str2);
 }

/* local definition */
/* declaration and assignment of local variables */
DefList:
    | Def DefList {
    char* name1=get_name_posi("Def",@1.first_line);
    char* str1=get_str2(name1,$1);
    char* name2=get_name_posi("DefList",@2.first_line);
    char* str2=get_str2(name2,$2);
    $$=get_str2(str1,str2);
    }
Def: Specifier DecList SEMI {
    char* name1=get_name_posi("Specifier",@1.first_line);
    char* str1=get_str2(name1,$1);
    char* name2=get_name_posi("DecList",@2.first_line);
    char* str2=get_str2(name1,$2);
    $$=get_str3(str1,str2,$3);
    }
DecList: Dec {
    char* name1=get_name_posi("Dec",@1.first_line);
    char* str1=get_str2(name1,$1);
    $$=str1;
    }
    | Dec COMMA DecList { 
    char* name1=get_name_posi("Dec",@1.first_line);
    char* str1=get_str2(name1,$1);
    char* name3=get_name_posi("DecList",@3.first_line);
    char* str3=get_str2(name3,$3);
    $$=get_str3(str1,$2,str3);
    }
Dec: VarDec {
    char* name1=get_name_posi("VarDec",@1.first_line);
    char* str1=get_str2(name1,$1);
    $$=str1;
    }
    | VarDec ASSIGN Exp { 
    char* name1=get_name_posi("VarDec",@1.first_line);
    char* str1=get_str2(name1,$1);
    char* name3=get_name_posi("Exp",@3.first_line);
    char* str3=get_str2(name3,$3);
    $$=get_str3(str1,$2,str3);
    }

/* Expression */
/* a single constant, or operations on variables */
Exp: Exp ASSIGN Exp { 
    char* name1=get_name_posi("Exp",@1.first_line);
    char* str1=get_str2(name1,$1);
    char* name3=get_name_posi("Exp",@3.first_line);
    char* str3=get_str2(name3,$3);
    $$=get_str3(str1,$2,str3);
    }
    | Exp AND Exp { 
    char* name1=get_name_posi("Exp",@1.first_line);
    char* str1=get_str2(name1,$1);
    char* name3=get_name_posi("Exp",@3.first_line);
    char* str3=get_str2(name3,$3);
    $$=get_str3(str1,$2,str3);
    }
    | Exp OR Exp { 
    char* name1=get_name_posi("Exp",@1.first_line);
    char* str1=get_str2(name1,$1);
    char* name3=get_name_posi("Exp",@3.first_line);
    char* str3=get_str2(name3,$3);
    $$=get_str3(str1,$2,str3);
    }
    | Exp LT Exp { 
    char* name1=get_name_posi("Exp",@1.first_line);
    char* str1=get_str2(name1,$1);
    char* name3=get_name_posi("Exp",@3.first_line);
    char* str3=get_str2(name3,$3);
    $$=get_str3(str1,$2,str3); }
    | Exp LE Exp { char* name1=get_name_posi("Exp",@1.first_line);
    char* str1=get_str2(name1,$1);
    char* name3=get_name_posi("Exp",@3.first_line);
    char* str3=get_str2(name3,$3);
    $$=get_str3(str1,$2,str3); }
    | Exp GT Exp { char* name1=get_name_posi("Exp",@1.first_line);
    char* str1=get_str2(name1,$1);
    char* name3=get_name_posi("Exp",@3.first_line);
    char* str3=get_str2(name3,$3);
    $$=get_str3(str1,$2,str3); }
    | Exp GE Exp { char* name1=get_name_posi("Exp",@1.first_line);
    char* str1=get_str2(name1,$1);
    char* name3=get_name_posi("Exp",@3.first_line);
    char* str3=get_str2(name3,$3);
    $$=get_str3(str1,$2,str3); }
    | Exp NE Exp { char* name1=get_name_posi("Exp",@1.first_line);
    char* str1=get_str2(name1,$1);
    char* name3=get_name_posi("Exp",@3.first_line);
    char* str3=get_str2(name3,$3);
    $$=get_str3(str1,$2,str3); }
    | Exp EQ Exp { char* name1=get_name_posi("Exp",@1.first_line);
    char* str1=get_str2(name1,$1);
    char* name3=get_name_posi("Exp",@3.first_line);
    char* str3=get_str2(name3,$3);
    $$=get_str3(str1,$2,str3); }
    | Exp PLUS Exp { char* name1=get_name_posi("Exp",@1.first_line);
    char* str1=get_str2(name1,$1);
    char* name3=get_name_posi("Exp",@3.first_line);
    char* str3=get_str2(name3,$3);
    $$=get_str3(str1,$2,str3); }
    | Exp MINUS Exp { char* name1=get_name_posi("Exp",@1.first_line);
    char* str1=get_str2(name1,$1);
    char* name3=get_name_posi("Exp",@3.first_line);
    char* str3=get_str2(name3,$3);
    $$=get_str3(str1,$2,str3); }
    | Exp MUL Exp { char* name1=get_name_posi("Exp",@1.first_line);
    char* str1=get_str2(name1,$1);
    char* name3=get_name_posi("Exp",@3.first_line);
    char* str3=get_str2(name3,$3);
    $$=get_str3(str1,$2,str3); }
    | Exp DIV Exp { char* name1=get_name_posi("Exp",@1.first_line);
    char* str1=get_str2(name1,$1);
    char* name3=get_name_posi("Exp",@3.first_line);
    char* str3=get_str2(name3,$3);
    $$=get_str3(str1,$2,str3); }
    | LP Exp RP {
    char* name2=get_name_posi("Exp",@2.first_line);
    char* str2=get_str2(name2,$2);
    $$=get_str3($1,str2,$3); }
    | MINUS Exp { 
    char* name2=get_name_posi("Exp",@2.first_line);
    char* str2=get_str2(name2,$2);
    $$=get_str2($1,str2); }
    | NOT Exp { char* name2=get_name_posi("Exp",@2.first_line);
    char* str2=get_str2(name2,$2);
    $$=get_str2($1,str2); }
    | ID LP Args RP { 
    char* name1=get_name_val("ID",$1);
    char* name3=get_name_posi("Args",@3.first_line);
    char* str3=get_str2(name3,$3);
    $$=get_str4(name1,$2,str3,$4);}
    | ID LP RP { 
    char* name1=get_name_val("ID",$1);
    $$=get_str3(name1,$2,$3); }
    | Exp LB Exp RB {
    char* name1=get_name_posi("Exp",@1.first_line);
    char* str1=get_str2(name1,$1);
    char* name3=get_name_posi("Exp",@3.first_line);
    char* str3=get_str2(name3,$3);
    $$=get_str4(str1,$2,str3,$4);}
    | Exp DOT ID {
    char* name1=get_name_posi("Exp",@1.first_line);
    char* str1=get_str2(name1,$1);
    char* name3=get_name_val("ID",$3);
    $$=get_str3(str1,$2,name3);
    }
    | ID { 
        $$= get_name_val("ID",$1);
    }
    | INT { 
        $$= get_name_val("INT",$1);
    }
    | FLOAT { 
        $$= get_name_val("FLOAT",$1);
    }
    | CHAR { 
        $$= get_name_val("CHAR",$1);
    }

Args: Exp COMMA Args {
     char* name1=get_name_posi("Exp",@1.first_line);
     char* str1=get_str2(name1,$1);
     free(name1);
     char* name3=get_name_posi("Args",@3.first_line);
     char* str3=get_str2(name3,$3);
     free(name3);
     $$=(char*)get_str3(name1,$2,name3);
    }
    | Exp {
        char* name1=get_name_posi("Exp",@1.first_line);
        char* str1=get_str2(name1,$1);
        $$=str1;
            }

%%
char* get_name_posi(const char* arg, int posi){
    char* name= (char *)malloc(50);
     if (name){
            sprintf(name, "%s (%d)\n",arg, posi);
        }
    return name;
}

char* get_name_val(const char* arg, const char* val){
    char* name= (char *)malloc(50);
     if (name){
            sprintf(name, "%s: %s\n",arg,val);
        }
    return name;
}

char* get_str6(const char* name, const char* str1,const char* str2,const char* str3,const char* str4,const char* str5){
    char* result = (char*)malloc(strlen(name)+strlen(str1) + strlen(str2) + strlen(str3) + strlen(str4) + strlen(str5) + 1);
    strcpy(result, name);  // Copy the first string
    strcat(result, str1);
    strcat(result, str2);  // Append the second string
    strcat(result, str3);  // Append the third string
    strcat(result, str4);
    strcat(result, str5);
    return result;
}

char* get_str5(const char* name, const char* str1,const char* str2,const char* str3,const char* str4){
    char* result = (char*)malloc(strlen(name)+strlen(str1) + strlen(str2) + strlen(str3) + strlen(str4) + 1);
    strcpy(result, name);  // Copy the first string
    strcat(result, str1);
    strcat(result, str2);  // Append the second string
    strcat(result, str3);  // Append the third string
    strcat(result, str4);
    return result;
}

char* get_str4(const char* name, const char* str1,const char* str2,const char* str3){
    char* result = (char*)malloc(strlen(name)+strlen(str1) + strlen(str2) + strlen(str3) + 1);
    strcpy(result, name);  // Copy the first string
    strcat(result, str1);
    strcat(result, str2);  // Append the second string
    strcat(result, str3);  // Append the third string
    return result;
}
char* get_str3(const char* name, const char* str1,const char* str2){
    char* result = (char*)malloc(strlen(name)+strlen(str1) + strlen(str2) + 1);
    strcpy(result, name);  // Copy the first string
    strcat(result, str1);
    strcat(result, str2);  // Append the second string
    return result;
}
char* get_str2(const char* name, const char* str1){
    char* result = (char*)malloc(strlen(name)+strlen(str1) + 1);
    strcpy(result, name);  // Copy the first string
    strcat(result, str1);
    return result;
}
void yyerror(const char* s) {
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