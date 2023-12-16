using namespace std;

#include <vector>
#include <string>

class node { //syntax tree node
    public:
        string type; //eg: "ID","VarDec","COMMA"
        vector<node*> children;
        string value; //only for leaf node: INT, ID

    node(string type): node(type, ""){}

    node(string type, string value): type(type), value(value){}

    node(string type, vector<node*> children): type(type), children(children){}
};
