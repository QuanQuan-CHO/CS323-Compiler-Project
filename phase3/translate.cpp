#define NEW_PLACE "#t"+to_string(count++)

#include <iostream>
#include <sstream>
#include "node.cpp"

int count = 1;

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
    for(node* child: n->children){
        res += child->type+" ";
    }
    if(!res.empty()){
        res.pop_back(); //remove last space
    }
    return res;
}

string translate_Exp(node* Exp, string place);

//For arithmetic Exp: "Exp PLUS/MINUS/MUL/DIV Exp"
string arithmetic_ir(char op, node* Exp, string place){
    node* Exp1 = Exp->children[0];
    node* Exp2 = Exp->children[2];
    string tp1 = NEW_PLACE;
    string tp2 = NEW_PLACE;
    string code1 = translate_Exp(Exp1,tp1);
    string code2 = translate_Exp(Exp2,tp2);
    string code3 = place+" := "+tp1+" "+op+" "+tp2;
    return code1+"\n"+code2+"\n"+code3;
}

string translate_Exp(node* Exp, string place){
    string children = expression(Exp);
    if(children=="INT"){
        return place+" := #"+Exp->children[0]->value;
    }else if(children=="ID"){
        return place+" := "+Exp->children[0]->value;
    }else if(children=="Exp ASSIGN Exp"){
        node* Exp1 = Exp->children[0];
        node* Exp2 = Exp->children[2];
        string tp = NEW_PLACE;
        string code1 = translate_Exp(Exp2,tp);
        string code2 = Exp1->value+" := "+tp;
        string code3 = place+" := "+Exp1->value;
        return code1+"\n"+code2+"\n"+code3;
    }else if(children=="Exp PLUS Exp"){
        return arithmetic_ir('+',Exp,place);
    }else if(children=="Exp MINUS Exp"){
        return arithmetic_ir('-',Exp,place);
    }else if(children=="Exp MUL Exp"){
        return arithmetic_ir('*',Exp,place);
    }else if(children=="Exp DIV Exp"){
        return arithmetic_ir('/',Exp,place);
    }else if(children=="MINUS Exp"){
        string tp = NEW_PLACE;
        string code1 = translate_Exp(Exp->children[1],tp);
        string code2 = place+" := #0 - "+tp;
        return code1+"\n"+code2;
    }else{ //conditional Exp
        
    }
}
