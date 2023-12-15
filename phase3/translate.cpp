#define NEW_PLACE "#t"+to_string(place_count++)
#define NEW_LABEL "label"+to_string(label_count++)

#include <iostream>
#include <sstream>
#include "node.cpp"

int place_count = 1;
int label_count = 1;

string shift(string str){
    stringstream in(str);
    stringstream out;
    string line;
    while(getline(in,line)){
        out << "  " << line << "\n";
    }
    return out.str();
}

string traverse(node* root){
    string res = root->type+"\n";
    for(node* child: root->children){
        res += shift(traverse(child));
    }
    return res;
}

//return string example: "Exp ASSIGN Exp"
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
        res += ir_vec[i]+"\n";
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
            "LABEL "+lb,
            translate_cond_Exp(nodes[2],lb_t,lb_f)
        );
    }else if(children=="Exp OR Exp"){
        string lb = NEW_LABEL;
        return concat_ir(
            translate_cond_Exp(nodes[0],lb_t,lb),
            "LABEL "+lb,
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

string translate_Exp(node* Exp, string place){
    vector<node*> nodes = Exp->children;
    string children = expression(Exp);
    if(children=="INT"){
        return place+" := #"+nodes[0]->value;
    }else if(children=="ID"){
        return place+" := "+nodes[0]->value;
    }else if(children=="CHAR"){

    }else if(children=="FLOAT"){

    }else if(children=="Exp ASSIGN Exp"){
        string tp = NEW_PLACE;
        return concat_ir(
            translate_Exp(nodes[2],tp),
            nodes[0]->value+" := "+tp,
            place+" := "+nodes[2]->value
        );
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

    }else if(children=="ID LP Args RP"){

    }else if(children=="ID LP RP"){

    }else if(children=="Exp LB Exp RB"){

    }else if(children=="Exp DOT ID"){

    }else{ //conditional Exp
        string lb1 = NEW_LABEL;
        string lb2 = NEW_LABEL;
        return concat_ir(
            place+" := #0",
            translate_cond_Exp(Exp,lb1,lb2),
            "LABEL "+lb1,
            place+" := #1",
            "LABEL "+lb2
        );
    }
}

string translate_Stmt(node* Stmt){
    vector<node*> nodes = Stmt->children;
    string children = expression(Stmt);
    if(children=="Exp SEMI"){
        return translate_Exp(nodes[0],NEW_PLACE);
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
            "LABEL "+lb1,
            translate_Stmt(nodes[4]),
            "LABEL "+lb2
        );
    }else if(children=="IF LP Exp RP Stmt ELSE Stmt"){
        string lb1 = NEW_LABEL;
        string lb2 = NEW_LABEL;
        string lb3 = NEW_LABEL;
        return concat_ir(
            translate_cond_Exp(nodes[2],lb1,lb2),
            "LABEL "+lb1,
            translate_Stmt(nodes[4]),
            "GOTO "+lb3,
            "LABEL "+lb2,
            translate_Stmt(nodes[6]),
            "LABEL "+lb3
        );
    }else if(children=="WHILE LP Exp RP Stmt"){
        string lb1 = NEW_LABEL;
        string lb2 = NEW_LABEL;
        string lb3 = NEW_LABEL;
        return concat_ir(
            "LABEL "+lb1,
            translate_cond_Exp(nodes[2],lb2,lb3),
            "LABEL "+lb2,
            translate_Stmt(nodes[4]),
            "GOTO "+lb1,
            "LABEL "+lb3
        );
    }else if(children=="CompSt"){
        
    }else{return "";} //never
}
