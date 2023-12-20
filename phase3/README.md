# CS323 Project Phase3

**12011619 Liquan Wang**

**12111744 Wenhui Tao**

**12111611 Ruixiang Jiang**



## Design

In this phase, we use the `node` class to generate the syntax tree during the bottom-up parsing process of Bison

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



## Optimization





## Extra Feature
