# CS323 Project Phase1

**12011619 Liquan Wang**

**12111744 Wenhui Tao**

**12111611 Ruixiang Jiang**



## Run

```shell
> make splc #compile the splc compiler for SPL language
> make test #compile the compiler and run test cases
> make clean #clean the directory
> make lexer #using lex.l to compile the lexer for debug 
```



## Flex

In the `lex.l` file

- `yylval` returns the `<name>\n` of the lexical unit, for example

  ``` c
  "{" {yylval=strdup("LC\n"); return LC;}

- We detect tokens in the correct format and tokens in the wrong format.

  - The correct token can help the **Bison** part to do syntax analysis

  - The wrong token can also help the bison to do error recovery and analyze the entire program

    ```c
    /* For example: invalid decimal and hex INT: starting with 0 */
    0[0-9]+|0[xX]0[0-9a-fA-F]+ {lexical_error(yytext,yylineno); return INT;}
    ```

  


## Bison

In the `syntax.y` file

- The various operators are defined from top to bottom in order of precedence from low to high.

  The priority is specified by text `%prec` to eliminate some ambiguity.

- Generate syntax tree:
  
  Instead of defining  `struct Node`, we use the function `concat_shift()` to truncate the next level of string by text `\n` and then add two spaces
  before each part

  In each production, we just need to use the `concat_shift()` as below to merge the syntax information in `$n` to `$$`
  
  This method's code implementation is simplier than the traditional `struct Node` method
  
  ```c
  FunDec:
    ID LP VarList RP {asprintf(&$$,"FunDec (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3,$4));}
  ```
  
  The function uses Variadic Template and Fold Expressions in C++17, so we should compile the `splc` use option `-std=c++17` in g++
  
  ```c++
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
  ```
  
  When the `splc` parse the program recursively, we can get the syntax tree as below
  
  ```
  Program (1)
    ExtDefList (1)
      ExtDef (1)
        Specifier (1)
          TYPE: int
        FunDec (1)
          ID: test_1_o02
          LP
          RP
        CompSt (2)
          LC
          DefList (3)
        ...
  ```
  



## Error detection

- In `lex.l` we detect the **lexical error**, and pass the right token to the parser as if the lexeme is right, so the syntax analysis process can continue without error

  For example, the code below recognizes the invalid decimal and hex `INT` token starting with 0

  ```c
  0[0-9]+|0[xX]0[0-9a-fA-F]+ {lexical_error(yytext,yylineno); return INT;}
  ```

  Moreover, we can also recognize the invalid `CHAR` token like below

  ```c
  '([^']|\\[xX](0|[1-9a-fA-F][0-9a-fA-F]?))' {asprintf(&yylval,"CHAR: %s\n",yytext); return CHAR;}
  '[^']*' {lexical_error(yytext,yylineno); return CHAR;} /*Invalid CHAR: not matched by the above valid CHAR regex will fail to this regex*/
  ```

- In `syntax.y` we detect the **syntax error** by matching the wrong sequence of terminals and nonterminals as below

  ```c
  ExtDef:
    Specifier ExtDecList SEMI {asprintf(&$$,"ExtDef (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3));}
  | Specifier ExtDecList error {syntax_error("semicolon \';\'",@2.last_line);}
  
  CompSt:
  ...
  /*The two error cases below indicate that declaration must before definition*/
  | LC DefList StmtList DefList error {syntax_error("specifier",@3.first_line);}
  | LC StmtList DefList error {syntax_error("specifier",@2.first_line);}
  ```

  

## Bonus

Beyond the basic requirement, we also implement some extra features

Because of aesthetic issues, the code is partially commented, but the actual program is not commented

To make the code more intuitive, we’ve attached test samples and results that you can skip if you don’t want to read them



### Single- and multi-line comment

```c
/*in lex.l*/
"//".*
"/*"((("*"[^/])?)|[^*])*"*/"
```



### Macro preprocessor and file inclusion

Enter the `<macro>` state after a special beginning is recognized to distinguish it from the exception recognition capture

```c
/*in lex.l*/
"#include" {yylval=strdup("INCLUDE\n"); BEGIN( macro); return INCLUDE;}
"#define" {yylval=strdup("DEFINE\n"); BEGIN(macro); return DEFINE;}
"#ifdef" {yylval=strdup("IFDEF\n"); BEGIN(macro); return IFDEF;}
"#else" {yylval=strdup("MACROELSE\n"); return MACROELSE;}
"#endif" {yylval=strdup("ENDIF\n"); return ENDIF;}
<macro>{
	"," {yylval=strdup("COMMA\n"); return COMMA;}
	"<" {return LT;}
	">" {return GT;}
	// \" {return DQUOT;}
	\n {BEGIN(INITIAL);}
    [ \t]+ /* ignore word splits */{}
	// [^," "<>"\n]+ {asprintf (&yylval ,"%s\n",yytext); return MACRO;}
}
```

Macro and file introduction automatically changes to the beginning of the file, and parallel output, to achieve `#define` `#ifdef` `#else` `#endif` `#include`

In the SPL file, we can define multiple macros on a single line separated by commas

```c
/*in syntax.y*/
RES:
  Program {if(!has_error){printf("%s", $1);}}
| MACROStmt Program {if(!has_error){printf("%s", $1);}}

MACROStmt:
  INCLUDEStmt {$$=$1;}
| DEFINEStmt {$$=$1;}
| DEFINEStmt MACROStmt {asprintf(&$$,"%s%s", $1,$2);}
| INCLUDEStmt MACROStmt {asprintf(&$$,"%s%s", $1,$2);}

INCLUDEStmt:
  INCLUDE LT MACRO GT {asprintf(&$$,"INCLUDE (%d)\n%s", @1.first_line ,concat_shift($3));}
| INCLUDE DQUOT MACRO DQUOT {asprintf(&$$,"INCLUDE (%d)\n%s", @1.first_line ,concat_shift($3));}

DEFINEStmt:
  DEFINE MACRO MACRO {asprintf(&$$,"DEFINE (%d)\n%s", @1.first_line ,concat_shift($2,$3));}
| DEFINEStmt COMMA MACRO MACRO {asprintf(&$$,"%sDEFINE (%d)\n%s",$1, @1.first_line ,concat_shift($3,$4));}

Stmt:
...
| IFDEF Stmt ENDIF {asprintf(&$$,"Stmt (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3));}
| IFDEF MACRO Stmt MACROELSE Stmt ENDIF {asprintf(&$$,"Stmt (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3,$4,$5));}
```



### For loop statement

```c
/*in lex.l*/
for {yylval=strdup("FOR\n"); return FOR;}
```

In the parser, the logic of `for` is very similar to `if` and `while`

```c
/*in syntax.y*/
Stmt:
...
| FOR LP Exp SEMI Exp SEMI Exp RP Stmt {
    asprintf(&$$,"Stmt (%d)\n%s\n", @$.first_line, concat_shift($1,$2,$3,$4,$5,$6,$7,$8,$9));
}
```

