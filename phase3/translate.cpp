#include <iostream>
#include <sstream>
#include "node.cpp"

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
