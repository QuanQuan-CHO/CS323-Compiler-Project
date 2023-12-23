# CS323 Project Phase3

**12011619 Liquan Wang**

**12111744 Wenhui Tao**

**12111611 Ruixiang Jiang**



## Design

In this phase, we generate the syntax tree using the `node` class during the bottom-up parsing process of Bison

```cpp
class node { //syntax tree node
    public:
        string type; //eg: "ID","VarDec","COMMA"
        vector<node*> children;
        string value; //only for leaf node: INT, ID
};
```

Then we can generate IR by traversing the syntax tree and using the provided translation scheme

For each nonterminal X, we define the function `translate_X()` and invoke the functions recursively, for example

```cpp
string translate_Args(node* Args, vector<string> &arg_list){
    vector<node*> nodes = Args->children;
    string children = expression(Args);
    if(children=="Exp"){
        string tp = NEW_PLACE;
        arg_list.push_back(tp);
        return translate_Exp(nodes[0],tp);
    }else if(children=="Exp COMMA Args"){
        string tp = NEW_PLACE;
        arg_list.push_back(tp);
        return concat_ir(
            translate_Exp(nodes[0],tp),
            translate_Args(nodes[2],arg_list)
        );
    }else{return "";} //never
}
```

The two macros below are used to generate new variables and labels

```cpp
#define NEW_PLACE "t"+to_string(place_count++)
#define NEW_LABEL "label"+to_string(label_count++)
int place_count = 1;
int label_count = 1;
```





## Extra Feature

### Compound Assignment Operator

To support the compound assignment operators:  `+= -= *= /= ++ --`, we first added six match rules in `lex.l`

```cpp
"+=" {yylval=new node("PLUS_ASSIGN"); return PLUS_ASSIGN;}
"-=" {yylval=new node("MINUS_ASSIGN"); return MINUS_ASSIGN;}
"*=" {yylval=new node("MUL_ASSIGN"); return MUL_ASSIGN;}
"/=" {yylval=new node("DIV_ASSIGN"); return DIV_ASSIGN;}
"++" {yylval=new node("SELF_PLUS"); return SELF_PLUS;}
"--" {yylval=new node("SELF_MINUS"); return SELF_MINUS;}
```

Then we just need to convert the compound expression to normal expression during the parsing process of Bison, by changing the syntax tree's structure: 

- convert `Exp1 [+-*/]= Exp2` to `Exp1 = Exp1 [+-*/] Exp2` 

  ```cpp
  node* convert_assign(node* Exp1, node* Exp2, string _operator){
      node* op = new node(_operator); //`operator` is an internal keyword in C++
      node* res = new node("Exp",vector{Exp1,op,Exp2});
      node* assign = new node("ASSIGN");
      return new node("Exp",vector{Exp1,assign,res});
  }
  
  %%
  Exp:
  ...
  | Exp PLUS_ASSIGN Exp {$$=convert_assign($1,$3,"PLUS");}
  | Exp MINUS_ASSIGN Exp {$$=convert_assign($1,$3,"MINUS");}
  | Exp MUL_ASSIGN Exp {$$=convert_assign($1,$3,"MUL");}
  | Exp DIV_ASSIGN Exp {$$=convert_assign($1,$3,"DIV");}
  %%
  ```

- convert `Exp[++|--]` to `Exp = Exp [+-] 1`

  ```cpp
  node* convert_self_assign(node* Exp, string _operator){ //`operator` is an internal keyword in C++
      node* one = new node("Exp", vector{new node("INT", "1")});
      return convert_assign(Exp, one, _operator);
  }
  
  %%
  Exp:
  ...
  | Exp SELF_PLUS {$$=convert_self_assign($1,"PLUS");}
  | Exp SELF_MINUS {$$=convert_self_assign($1,"MINUS");}
  %%
  ```

After the preprocess of compound assignment operator, we can normally apply the translation scheme during the top-down traverse



### For Loop

To support for loop, we added four productions in `syntax.y`

```cpp
Stmt:
  ...
  //for(...;...;...){...}
| FOR LP Def Exp SEMI Exp RP Stmt {$$=new node("Stmt",vector{$1,$2,$3,$4,$5,$6,$7,$8});}
  //for(...;...;){...}
| FOR LP Def Exp SEMI RP Stmt {$$=new node("Stmt",vector{$1,$2,$3,$4,$5,$6,$7});}    
  //for(;...;...){...}
| FOR LP SEMI Exp SEMI Exp RP Stmt {$$=new node("Stmt",vector{$1,$2,$3,$4,$5,$6,$7,$8});}
  //for(;...;){...}
| FOR LP SEMI Exp SEMI RP Stmt {$$=new node("Stmt",vector{$1,$2,$3,$4,$5,$6,$7});}
```

While traversing the syntax tree, we just need to translate the for loop like while loop, below is the example translation scheme for `for(...;...;...){...}`

```cpp
if(children=="FOR LP Def Exp SEMI Exp RP Stmt"){
    string lb1 = NEW_LABEL;
    string lb2 = NEW_LABEL;
    string lb3 = NEW_LABEL;
    string ir1 = translate_Def(nodes[2]);
    string ir2 = "LABEL "+lb1+" :";
    string ir3 = translate_cond_Exp(nodes[3],lb2,lb3);
    string ir4 = "LABEL "+lb2+" :";
    string ir5 = translate_Stmt(nodes[7]);
    string ir6 = translate_Exp(nodes[5],""); //no need to store the result
    string ir7 = "GOTO "+lb1;
    string ir8 = "LABEL "+lb3+" :";
    return concat_ir(ir1,ir2,ir3,ir4,ir5,ir6,ir7,ir8);
}
```

