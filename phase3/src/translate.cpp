#define NEW_PLACE "t"+to_string(place_count++)
#define NEW_LABEL "label"+to_string(label_count++)

#include <iostream>
#include <sstream>
#include <unordered_map>
#include "node.cpp"

int place_count = 1;
int label_count = 1;

/*array_name -> {size1,size2,...}, store the array size of each level
  for example:
- if a[6] is declared, then the entry is a->{1}
- if b[6][8] is declared, then the entry is b->{1,8}
- if c[6][8][7] is declared, then the entry is c->{1,7,7*8}, i.e:c->{1,7,56}
- if d[6][8][7][3] is declared, then the entry is d->{1,3,3*7,3*7*8}, i.e:d->{1,3,21,168}
*/
unordered_map<string,vector<int>> arrays = {};

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
    for(int i=0;i<ir_vec.size();i++){
        if(ir_vec[i]!=""){
            res += ir_vec[i]+"\n";
        }
    }
    if(res!=""){
        res.pop_back(); //remove the last '\n'
    }
    return res;
}

string translate_Exp(node* Exp, string* place);

//For arithmetic Exp: "Exp PLUS/MINUS/MUL/DIV Exp"
string arithmetic_ir(char op, vector<node*> nodes, string place){
    string tp1 = NEW_PLACE;
    string tp2 = NEW_PLACE;
    string ir1 = translate_Exp(nodes[0],&tp1);
    string ir2 = translate_Exp(nodes[2],&tp2);
    string ir3 = place+" := "+tp1+" "+op+" "+tp2;
    return concat_ir(ir1,ir2,ir3);
}

//For conditional Exp: "Exp EQ/NE/LE/LT/GT/GE Exp"
string comparison_ir(string op, vector<node*> nodes, string lb_t, string lb_f){
    string tp1 = NEW_PLACE;
    string tp2 = NEW_PLACE;
    string ir1 = translate_Exp(nodes[0],&tp1);
    string ir2 = translate_Exp(nodes[2],&tp2);
    string ir3 = "IF "+tp1+" "+op+" "+tp2+" GOTO "+lb_t;
    string ir4 = "GOTO "+lb_f;
    return concat_ir(ir1,ir2,ir3,ir4);
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
        string ir1 = translate_cond_Exp(nodes[0],lb,lb_f);
        string ir2 = "LABEL "+lb+" :";
        string ir3 = translate_cond_Exp(nodes[2],lb_t,lb_f);
        return concat_ir(ir1,ir2,ir3);
    }else if(children=="Exp OR Exp"){
        string lb = NEW_LABEL;
        string ir1 = translate_cond_Exp(nodes[0],lb_t,lb);
        string ir2 = "LABEL "+lb+" :";
        string ir3 = translate_cond_Exp(nodes[2],lb_t,lb_f);
        return concat_ir(ir1,ir2,ir3);
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
        return translate_Exp(nodes[0],&tp);
    }else if(children=="Exp COMMA Args"){
        string tp = NEW_PLACE;
        string ir1 = translate_Exp(nodes[0],&tp);
        arg_list.push_back(tp);
        string ir2 = translate_Args(nodes[2],arg_list);
        return concat_ir(ir1,ir2);
    }else{return "";} //never
}

/*[place]: the place to store the result of Exp
           place==nullptr means that the Exp result needn't to store */
string translate_Exp(node* Exp, string* place){
    vector<node*> nodes = Exp->children;
    string children = expression(Exp);
    if(nodes.size()==1){ //INT ID CHAR FLOAT
        return *place+" := "+nodes[0]->value;
    }else if(children=="Exp ASSIGN Exp"){
        if(expression(nodes[0])=="ID"){
            string var_name = nodes[0]->children[0]->value;
            string Exp2_ir = translate_Exp(nodes[2],&var_name);
            if(place!=nullptr){ 
                return concat_ir(
                    Exp2_ir,
                    *place+" := "+var_name
                );
            }else{return Exp2_ir;} //no need to store the result
        }else{ //nodes[0] is array entry: Exp LB Exp RB
            //Process Exp1
            string Exp1_ir = translate_Exp(nodes[0],nullptr);
            int lastline_index = Exp1_ir.find_last_of('\n');
            string array_ir = Exp1_ir.substr(0,lastline_index);
            string address = Exp1_ir.substr(lastline_index+1);

            if(place!=nullptr){ 
                return concat_ir(
                    array_ir,
                    translate_Exp(nodes[2], &address),
                    *place+" := "+address
                );
            }else{ //no need to store the result
                return concat_ir(
                    array_ir,
                    translate_Exp(nodes[2], &address)
                );
            }
        }
    }else if(children=="Exp PLUS Exp"){
        return arithmetic_ir('+',nodes,*place);
    }else if(children=="Exp MINUS Exp"){
        return arithmetic_ir('-',nodes,*place);
    }else if(children=="Exp MUL Exp"){
        return arithmetic_ir('*',nodes,*place);
    }else if(children=="Exp DIV Exp"){
        return arithmetic_ir('/',nodes,*place);
    }else if(children=="MINUS Exp"){
        string tp = NEW_PLACE;
        return concat_ir(
            translate_Exp(nodes[1],&tp),
            *place+" := #0 - "+tp
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
                translate_Exp(nodes[2],&tp),
                "WRITE "+tp
            );
        }else{
            if(place==nullptr){
                /*no need to store the result in .spl source code,
                  but we need to store the result in a useless place,
                  in order to use IR: "x := CALL f", since there is no IR like "CALL f" */
                place = new string;
                *place = NEW_PLACE;
            }
            vector<string> arg_list = {};
            string code1 = translate_Args(nodes[2],arg_list);
            string code2 = "";
            for(int i=arg_list.size()-1;i>=0;i--){
                code2 += "ARG "+arg_list[i]+"\n";
            }
            return code1+"\n"+code2+*place+" := CALL "+function;
        }
    }else if(children=="ID LP RP"){
        string function = nodes[0]->value;
        if(function=="read"){
            return "READ "+*place;
        }else{
            if(place==nullptr){
                /*no need to store the result in .spl source code,
                  but we need to store the result in a useless place,
                  in order to use IR: "x := CALL f", since there is no IR like "CALL f" */
                place = new string;
                *place = NEW_PLACE;
            }
            return *place+" := CALL "+function;
        }
    }else if(children=="Exp LB Exp RB"){
        node* Exp1 = Exp;
        do{ //first, iterate to find out the array_name
            Exp1 = Exp1->children[0];
            nodes = Exp1->children;
        }while(expression(Exp1)=="Exp LB Exp RB");
        string array_name = nodes[0]->value; //here, nodes[0] must be `ID`
        vector<int> sizes = arrays[array_name];

        Exp1 = Exp;
        nodes = Exp1->children;
        int offset = 0;
        //second, iterate to calculate the offset
        string ir = "";
        string _offset = NEW_PLACE;
        ir += _offset+" := #0\n";
        for(int k=0;expression(Exp1)=="Exp LB Exp RB";k++){
            string tp = NEW_PLACE;
            ir += translate_Exp(nodes[2],&tp)+"\n";
            ir += tp+" := "+tp+" * #"+to_string(sizes[k])+"\n";
            ir += _offset+" := "+_offset+" + "+tp+"\n";
            Exp1 = Exp1->children[0];
            nodes = Exp1->children;
        }

        string address = NEW_PLACE;
        ir += _offset+" := "+_offset+" * #4\n";
        ir += address+" := &"+array_name+" + "+_offset+"\n";
        if(place==nullptr){
            /*no need to store the result, return the array entry's address,
              Exp appears on left of "=", need to assign the array entry with another value
              for example: a[1][2]=4 */
            return ir+"*"+address;
        }else{ //`place` is not empty
            /*need to store the result in the `place` address
              Exp appears on right of "=", the array entry's value needs to be assigned to another variable
              for example: b=a[3][6];
            */
            return ir+*place+" := *"+address;
        }
    }else if(children=="Exp DOT ID"){
        return ""; //never, because there are no structures (Assumption 6)
    }else{ //conditional Exp
        string lb1 = NEW_LABEL;
        string lb2 = NEW_LABEL;
        return concat_ir(
            *place+" := #0",
            translate_cond_Exp(Exp,lb1,lb2),
            "LABEL "+lb1+" :",
            *place+" := #1",
            "LABEL "+lb2+" :"
        );
    }
}

string translate_VarDec(node* VarDec){
    vector<node*> nodes = VarDec->children;
    string children = expression(VarDec);
    if(children=="ID"){
        return nodes[0]->value;
    }else if(children=="VarDec LB INT RB"){
        int count = 1;
        vector<int> sizes= {};
        do{//iterate multi-level array
            sizes.push_back(count);
            count *= stoi(nodes[2]->value.substr(1)); //delete the first '#' in INT
            VarDec = VarDec->children[0];
            nodes = VarDec->children;
        }while(expression(VarDec)=="VarDec LB INT RB");
        string array_name = nodes[0]->value; //here, nodes[0] must be `ID`
        arrays.insert({array_name,sizes});
        return "DEC "+array_name+" "+to_string(count*4); //each int's size is 4 byte
    }else{return "";} //never
}

string translate_Dec(node* Dec){
    vector<node*> nodes = Dec->children;
    string children = expression(Dec);
    if(children=="VarDec"){
        if(expression(nodes[0])=="VarDec LB INT RB"){
            return translate_VarDec(nodes[0]); //only array declaration needs to be translated
        }else{return "";}
    }else if(children=="VarDec ASSIGN Exp"){
        //here, there must be VarDec: ID
        string var_name = nodes[0]->children[0]->value;
        return translate_Exp(nodes[2], &var_name);
    }else{return "";} //never
}

string translate_DecList(node* DecList){
    vector<node*> nodes = DecList->children;
    string children = expression(DecList);
    if(children=="Dec"){
        return translate_Dec(nodes[0]);
    }else if(children=="Dec COMMA DecList"){
        string ir1 = translate_Dec(nodes[0]);
        string ir2 = translate_DecList(nodes[2]);
        return concat_ir(ir1,ir2);
    }else{return "";} //never
}

string translate_Def(node* Def){ //Def: Specifier DecList SEMI
    return translate_DecList(Def->children[1]);
}

string translate_DefList(node* DefList){
    vector<node*> nodes = DefList->children;
    string children = expression(DefList);
    if(children=="Def DefList"){
        string ir1 = translate_Def(nodes[0]);
        string ir2 = translate_DefList(nodes[1]);
        return concat_ir(ir1,ir2);
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
        return translate_Exp(nodes[0],nullptr);
    }else if(children=="RETURN Exp SEMI"){
        string tp = NEW_PLACE;
        return concat_ir(
            translate_Exp(nodes[1],&tp),
            "RETURN "+tp
        );
    }else if(children=="IF LP Exp RP Stmt"){
        string lb1 = NEW_LABEL;
        string lb2 = NEW_LABEL;
        string ir1 = translate_cond_Exp(nodes[2],lb1,lb2);
        string ir2 = "LABEL "+lb1+" :";
        string ir3 = translate_Stmt(nodes[4]);
        string ir4 = "LABEL "+lb2+" :";
        return concat_ir(ir1,ir2,ir3,ir4);
    }else if(children=="IF LP Exp RP Stmt ELSE Stmt"){
        string lb1 = NEW_LABEL;
        string lb2 = NEW_LABEL;
        string lb3 = NEW_LABEL;
        string ir1 = translate_cond_Exp(nodes[2],lb1,lb2);
        string ir2 = "LABEL "+lb1+" :";
        string ir3 = translate_Stmt(nodes[4]);
        string ir4 = "GOTO "+lb3;
        string ir5 = "LABEL "+lb2+" :";
        string ir6 = translate_Stmt(nodes[6]);
        string ir7 = "LABEL "+lb3+" :";
        return concat_ir(ir1,ir2,ir3,ir4,ir5,ir6,ir7);
    }else if(children=="WHILE LP Exp RP Stmt"){
        string lb1 = NEW_LABEL;
        string lb2 = NEW_LABEL;
        string lb3 = NEW_LABEL;
        string ir1 = "LABEL "+lb1+" :";
        string ir2 = translate_cond_Exp(nodes[2],lb2,lb3);
        string ir3 = "LABEL "+lb2+" :";
        string ir4 = translate_Stmt(nodes[4]);
        string ir5 = "GOTO "+lb1;
        string ir6 = "LABEL "+lb3+" :";
        return concat_ir(ir1,ir2,ir3,ir4,ir5,ir6);
    }else if(children=="CompSt"){
        return translate_CompSt(nodes[0]);
    }else if(children=="FOR LP Def Exp SEMI Exp RP Stmt"){
        string lb1 = NEW_LABEL;
        string lb2 = NEW_LABEL;
        string lb3 = NEW_LABEL;
        //for(...;...;...){...}
        string ir1 = translate_Def(nodes[2]);
        string ir2 = "LABEL "+lb1+" :";
        string ir3 = translate_cond_Exp(nodes[3],lb2,lb3);
        string ir4 = "LABEL "+lb2+" :";
        string ir5 = translate_Stmt(nodes[7]);
        string ir6 = translate_Exp(nodes[5],nullptr); //no need to store the result
        string ir7 = "GOTO "+lb1;
        string ir8 = "LABEL "+lb3+" :";
        return concat_ir(ir1,ir2,ir3,ir4,ir5,ir6,ir7,ir8);
    }else if(children=="FOR LP Def Exp SEMI RP Stmt"){
        string lb1 = NEW_LABEL;
        string lb2 = NEW_LABEL;
        string lb3 = NEW_LABEL;
        //for(...;...;){...}
        string ir1 = translate_Def(nodes[2]);
        string ir2 = "LABEL "+lb1+" :";
        string ir3 = translate_cond_Exp(nodes[3],lb2,lb3);
        string ir4 = "LABEL "+lb2+" :";
        string ir5 = translate_Stmt(nodes[6]);
        string ir6 = "GOTO "+lb1;
        string ir7 = "LABEL "+lb3+" :";
        return concat_ir(ir1,ir2,ir3,ir4,ir5,ir6,ir7);
    }else if(children=="FOR LP SEMI Exp SEMI Exp RP Stmt"){
        string lb1 = NEW_LABEL;
        string lb2 = NEW_LABEL;
        string lb3 = NEW_LABEL;
        //for(;...;...){...}
        string ir1 = "LABEL "+lb1+" :";
        string ir2 = translate_cond_Exp(nodes[3],lb2,lb3);
        string ir3 = "LABEL "+lb2+" :";
        string ir4 = translate_Stmt(nodes[7]);
        string ir5 = translate_Exp(nodes[5],nullptr); //no need to store the result
        string ir6 = "GOTO "+lb1;
        string ir7 = "LABEL "+lb3+" :";
        return concat_ir(ir1,ir2,ir3,ir4,ir5,ir6,ir7);
    }else if(children=="FOR LP SEMI Exp SEMI RP Stmt"){
        string lb1 = NEW_LABEL;
        string lb2 = NEW_LABEL;
        string lb3 = NEW_LABEL;
        //for(;...;){...}
        string ir1 = "LABEL "+lb1+" :";
        string ir2 = translate_cond_Exp(nodes[3],lb2,lb3);
        string ir3 = "LABEL "+lb2+" :";
        string ir4 = translate_Stmt(nodes[6]);
        string ir5 = "GOTO "+lb1;
        string ir6 = "LABEL "+lb3+" :";
        return concat_ir(ir1,ir2,ir3,ir4,ir5,ir6);
    }else{return "";} //never
}

string translate_StmtList(node* StmtList){
    vector<node*> nodes = StmtList->children;
    string children = expression(StmtList);
    if(children=="Stmt StmtList"){
        string ir1 = translate_Stmt(nodes[0]);
        string ir2 = translate_StmtList(nodes[1]);
        return concat_ir(ir1,ir2);
    }else if(children=="Stmt"){
        return translate_Stmt(nodes[0]);
    }else{return "";} //never
}

string translate_CompSt(node* CompSt){
    vector<node*> nodes = CompSt->children;
    string children = expression(CompSt);
    if(children=="LC DefList StmtList RC"){
        string ir1 = translate_DefList(nodes[1]);
        string ir2 = translate_StmtList(nodes[2]);
        return concat_ir(ir1,ir2);
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
        string ir1 = translate_VarDec(nodes[0]);
        string ir2 = translate_ExtDecList(nodes[2]);
        return concat_ir(ir1,ir2);
    }else{return "";} //never
}

//ParamDec: Specifier VarDec
string translate_ParamDec(node* ParamDec){
    vector<node*> nodes = ParamDec->children;
    return "PARAM "+translate_VarDec(nodes[1]);
}

string translate_VarList(node* VarList){
    vector<node*> nodes = VarList->children;
    string ir1 = translate_ParamDec(nodes[0]);
    string ir2 = expression(VarList) == "ParamDec COMMA VarList" ?
                 translate_VarList(nodes[2]) :
                 ""; //ParamDec
    return concat_ir(ir1,ir2);
}

string translate_FunDec(node* FunDec){
    vector<node*> nodes = FunDec->children;
    string name = nodes[0]->value;
    return concat_ir(
        "FUNCTION "+name+" :",
        expression(FunDec) == "ID LP VarList RP" ?
        translate_VarList(nodes[2]) :
        "" //ID LP RP: without parameters
    );
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
        string ir1 = translate_FunDec(nodes[1]);
        string ir2 = translate_CompSt(nodes[2])+"\n"; //add newline to separate different functions
        return concat_ir(ir1,ir2);
    }else{return "";} //Specifier SEMI
}

string translate_ExtDefList(node* ExtDefList){
    vector<node*> nodes = ExtDefList->children;
    if(nodes.empty()){
        return "";
    }else{ //ExtDef ExtDefList
        string ir1 = translate_ExtDef(nodes[0]);
        string ir2 = translate_ExtDefList(nodes[1]);
        return concat_ir(ir1,ir2);
    }
}
