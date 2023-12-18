#define NEW_PLACE "t"+to_string(place_count++)
#define NEW_LABEL "label"+to_string(label_count++)

#include <iostream>
#include <sstream>
#include "node.cpp"

int place_count = 1;
int label_count = 1;

//for debug
string shift(string str){
    stringstream in(str);
    stringstream out;
    string line;
    while(getline(in,line)){
        out << "  " << line << "\n";
    }
    return out.str();
}

//for debug
string traverse(node* root){
    string res = root->type+"\n";
    for(node* child: root->children){
        res += shift(traverse(child));
    }
    return res;
}

//return expression of children nodes
//example: "Exp ASSIGN Exp"
string expression(node* n){
    string res = "";
    for(int i=0;i < n->children.size()-1;i++){
        res += n->children[i]->type+" ";
    }
    return res + n->children.back()->type;
}

template<typename... IRs>
string concat_ir(IRs... irs){
    vector<string> ir_vec = {irs...};
    string res = "";
    for(int i=0;i < ir_vec.size()-1;i++){
        if(ir_vec[i]!=""){
            res += ir_vec[i]+"\n";
        }
    }
    return res+ir_vec.back();
}

string translate_Exp(node* Exp, string place);

//For arithmetic Exp: "Exp PLUS/MINUS/MUL/DIV Exp"
string arithmetic_ir(char op, vector<node*> nodes, string place){
    string tp1 = NEW_PLACE;
    string tp2 = NEW_PLACE;
    return concat_ir(
        translate_Exp(nodes[0],tp1),
        translate_Exp(nodes[2],tp2),
        place+" := "+tp1+" "+op+" "+tp2
    );
}

//For conditional Exp: "Exp EQ/NE/LE/LT/GT/GE Exp"
string comparison_ir(string op, vector<node*> nodes, string lb_t, string lb_f){
    string tp1 = NEW_PLACE;
    string tp2 = NEW_PLACE;
    return concat_ir(
        translate_Exp(nodes[0],tp1),
        translate_Exp(nodes[2],tp2),
        "IF "+tp1+" "+op+" "+tp2+" GOTO "+lb_t,
        "GOTO "+lb_f
    );
}

string translate_cond_Exp(node* Exp, string lb_t, string lb_f){
    vector<node*> nodes = Exp->children;
    string children = expression(Exp);
    if(children=="Exp EQ Exp"){
        return comparison_ir("==",nodes,lb_t,lb_f);
    }else if(children=="Exp NE Exp"){
        return comparison_ir("!=",nodes,lb_t,lb_f);
    }else if(children=="Exp LE Exp"){
        return comparison_ir("<=",nodes,lb_t,lb_f);
    }else if(children=="Exp LT Exp"){
        return comparison_ir("<",nodes,lb_t,lb_f);
    }else if(children=="Exp GT Exp"){
        return comparison_ir(">",nodes,lb_t,lb_f);
    }else if(children=="Exp GE Exp"){
        return comparison_ir(">=",nodes,lb_t,lb_f);
    }else if(children=="Exp AND Exp"){
        string lb = NEW_LABEL;
        return concat_ir(
            translate_cond_Exp(nodes[0],lb,lb_f),
            "LABEL "+lb+" :",
            translate_cond_Exp(nodes[2],lb_t,lb_f)
        );
    }else if(children=="Exp OR Exp"){
        string lb = NEW_LABEL;
        return concat_ir(
            translate_cond_Exp(nodes[0],lb_t,lb),
            "LABEL "+lb+" :",
            translate_cond_Exp(nodes[2],lb_t,lb_f)
        );
    }else if(children=="NOT Exp"){
        return translate_cond_Exp(nodes[1],lb_f,lb_t);
    }else{return "";} //never
}

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

/*[place]: the place to store the result of Exp
           place=="" means that the Exp result needn't to store */
string translate_Exp(node* Exp, string place){
    vector<node*> nodes = Exp->children;
    string children = expression(Exp);
    if(children=="INT"){
        return place+" := #"+nodes[0]->value;
    }else if(children=="ID"){
        return place+" := "+nodes[0]->value;
    }else if(children=="CHAR" || children=="FLOAT"){
        return ""; //never, because there is only INT primitive type (Assumption 2)
    }else if(children=="Exp ASSIGN Exp"){
        /*In this case, there must be `Exp1->ID`
          because there is no struct or array (Assumption 6)*/
        string var_name = nodes[0]->children[0]->value;
        string Exp2_ir = translate_Exp(nodes[2],var_name);
        if(place!=""){ 
            return concat_ir(
                Exp2_ir,
                place+" := "+var_name
            );
        }else{return Exp2_ir;} //no need to store the result
    }else if(children=="Exp PLUS Exp"){
        return arithmetic_ir('+',nodes,place);
    }else if(children=="Exp MINUS Exp"){
        return arithmetic_ir('-',nodes,place);
    }else if(children=="Exp MUL Exp"){
        return arithmetic_ir('*',nodes,place);
    }else if(children=="Exp DIV Exp"){
        return arithmetic_ir('/',nodes,place);
    }else if(children=="MINUS Exp"){
        string tp = NEW_PLACE;
        return concat_ir(
            translate_Exp(nodes[1],tp),
            place+" := #0 - "+tp
        );
    }else if(children=="LP Exp RP"){
        return translate_Exp(nodes[1],place);
    }else if(children=="ID LP Args RP"){
        string function = nodes[0]->value;
        if(function=="write"){
            node* Args = nodes[2]; //in this case, there must be `Args->Exp`
            nodes[2]=Args->children[0]; //replace the `Args` with `Exp`
            //The children now becomes `ID LP Exp RP`
            string tp = NEW_PLACE;
            return concat_ir(
                translate_Exp(nodes[2],tp),
                "WRITE "+tp
            );
        }else{
            if(place==""){
                /*no need to store the result in .spl source code,
                  but we need to store the result in a useless place,
                  in order to use IR: "x := CALL f", since there is no IR like "CALL f" */
                place = NEW_PLACE;
            }
            vector<string> arg_list = {};
            string code1 = translate_Args(nodes[2],arg_list);
            string code2 = "";
            for(int i=arg_list.size()-1;i>=0;i--){
                code2 += "ARG "+arg_list[i]+"\n";
            }
            return code1+"\n"+code2+place+" := CALL "+function;
        }
    }else if(children=="ID LP RP"){
        string function = nodes[0]->value;
        if(function=="read"){
            return "READ "+place;
        }else{
            if(place==""){
                /*no need to store the result in .spl source code,
                  but we need to store the result in a useless place,
                  in order to use IR: "x := CALL f", since there is no IR like "CALL f" */
                place = NEW_PLACE;
            }
            return place+" := CALL "+function;
        }
    }else if(children=="Exp LB Exp RB"){
        return ""; //never, because there are no arrays (Assumption 6)
    }else if(children=="Exp DOT ID"){
        return ""; //never, because there are no structures (Assumption 6)
    }else{ //conditional Exp
        string lb1 = NEW_LABEL;
        string lb2 = NEW_LABEL;
        return concat_ir(
            place+" := #0",
            translate_cond_Exp(Exp,lb1,lb2),
            "LABEL "+lb1+" :",
            place+" := #1",
            "LABEL "+lb2+" :"
        );
    }
}

string translate_VarDec(node* VarDec){
    vector<node*> nodes = VarDec->children;
    string children = expression(VarDec);
    if(children=="ID"){
        return nodes[0]->value;
    }else{return "";} //[VarDec LB INT RB] no need to implement array (Assumption 6)
}

string translate_Dec(node* Dec){
    vector<node*> nodes = Dec->children;
    string children = expression(Dec);
    if(children=="VarDec"){
        return "";
    }else if(children=="VarDec ASSIGN Exp"){
        /*In this case, there must be `VarDec->ID`
          because there is no array (Assumption 6)*/
        string var_name = nodes[0]->children[0]->value;
        return translate_Exp(nodes[2], var_name);
    }else{return "";} //never
}

string translate_DecList(node* DecList){
    vector<node*> nodes = DecList->children;
    string children = expression(DecList);
    if(children=="Dec"){
        return translate_Dec(nodes[0]);
    }else if(children=="Dec COMMA DecList"){
        return concat_ir(
            translate_Dec(nodes[0]),
            translate_DecList(nodes[2])
        );
    }else{return "";} //never
}

string translate_Def(node* Def){ //Def: Specifier DecList SEMI
    return translate_DecList(Def->children[1]);
}

string translate_DefList(node* DefList){
    vector<node*> nodes = DefList->children;
    string children = expression(DefList);
    if(children=="Def DefList"){
        return concat_ir(
            translate_Def(nodes[0]),
            translate_DefList(nodes[1])
        );
    }else if(children=="Def"){
        return translate_Def(nodes[0]);
    }else{return "";} //never
}

string translate_CompSt(node* CompSt);

string translate_Stmt(node* Stmt){
    vector<node*> nodes = Stmt->children;
    string children = expression(Stmt);
    if(children=="Exp SEMI"){
        /*in this case, there is no need to store the Exp result,
          so `place` is useless in Exp translation*/
        return translate_Exp(nodes[0],"");
    }else if(children=="RETURN Exp SEMI"){
        string tp = NEW_PLACE;
        return concat_ir(
            translate_Exp(nodes[1],tp),
            "RETURN "+tp
        );
    }else if(children=="IF LP Exp RP Stmt"){
        string lb1 = NEW_LABEL;
        string lb2 = NEW_LABEL;
        return concat_ir(
            translate_cond_Exp(nodes[2],lb1,lb2),
            "LABEL "+lb1+" :",
            translate_Stmt(nodes[4]),
            "LABEL "+lb2+" :"
        );
    }else if(children=="IF LP Exp RP Stmt ELSE Stmt"){
        string lb1 = NEW_LABEL;
        string lb2 = NEW_LABEL;
        string lb3 = NEW_LABEL;
        return concat_ir(
            translate_cond_Exp(nodes[2],lb1,lb2),
            "LABEL "+lb1+" :",
            translate_Stmt(nodes[4]),
            "GOTO "+lb3,
            "LABEL "+lb2+" :",
            translate_Stmt(nodes[6]),
            "LABEL "+lb3+" :"
        );
    }else if(children=="WHILE LP Exp RP Stmt"){
        string lb1 = NEW_LABEL;
        string lb2 = NEW_LABEL;
        string lb3 = NEW_LABEL;
        return concat_ir(
            "LABEL "+lb1+" :",
            translate_cond_Exp(nodes[2],lb2,lb3),
            "LABEL "+lb2+" :",
            translate_Stmt(nodes[4]),
            "GOTO "+lb1,
            "LABEL "+lb3+" :"
        );
    }else if(children=="CompSt"){
        return translate_CompSt(nodes[0]);
    }else{return "";} //never
}

string translate_StmtList(node* StmtList){
    vector<node*> nodes = StmtList->children;
    string children = expression(StmtList);
    if(children=="Stmt StmtList"){
        return concat_ir(
            translate_Stmt(nodes[0]),
            translate_StmtList(nodes[1])
        );
    }else if(children=="Stmt"){
        return translate_Stmt(nodes[0]);
    }else{return "";} //never
}

string translate_CompSt(node* CompSt){
    vector<node*> nodes = CompSt->children;
    string children = expression(CompSt);
    if(children=="LC DefList StmtList RC"){
        return concat_ir(
            translate_DefList(nodes[1]),
            translate_StmtList(nodes[2])
        );
    }else if(children=="LC StmtList RC"){
        return translate_StmtList(nodes[1]);
    }else if(children=="LC DefList RC"){
        return translate_DefList(nodes[1]);
    }else{return "";} //never
}

string translate_ExtDecList(node* ExtDecList){
    vector<node*> nodes = ExtDecList->children;
    string children = expression(ExtDecList);
    if(children=="VarDec"){
        return translate_VarDec(nodes[0]);
    }else if(children=="VarDec COMMA ExtDecList"){
        return concat_ir(
            translate_VarDec(nodes[0]),
            translate_ExtDecList(nodes[2])
        );
    }else{return "";} //never
}

string translate_FunDec(node* FunDec){
    /*FunDec:
        ID LP RP
      | ID LP VarList RP  
    */
    string name = FunDec->children[0]->value;
    return "FUNCTION "+name+" :";
}

string translate_ExtDef(node* ExtDef){
    /*According to:
      - Assumption 2: there are only integer primitive type variables
      - Assumption 6: there are no structure variables or arrays
      The `Specifier` here must be `int`
    */
    vector<node*> nodes = ExtDef->children;
    string children = expression(ExtDef);
    if(children=="Specifier ExtDecList SEMI"){
        return translate_ExtDecList(nodes[1]);
    }else if(children=="Specifier FunDec CompSt"){
        return concat_ir(
            translate_FunDec(nodes[1]),
            translate_CompSt(nodes[2])+"\n"
        );
    }else{return "";} //Specifier SEMI
}

string translate_ExtDefList(node* ExtDefList){
    vector<node*> nodes = ExtDefList->children;
    if(nodes.empty()){
        return "";
    }else{ //ExtDef ExtDefList
        return concat_ir(
            translate_ExtDef(nodes[0]),
            translate_ExtDefList(nodes[1])
        );
    }
}
