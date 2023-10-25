#include "tree.hpp"

// 初始化映射
std::map<std::string, std::string> nameToCategory = {
    {"STRUCT", "TERMINAL"},
    {"IF", "TERMINAL"},
    {"ELSE", "TERMINAL"},
    {"WHILE", "TERMINAL"},
    {"RETURN", "TERMINAL"},
    {"SEMI", "TERMINAL"},
    {"COMMA", "TERMINAL"},
    {"EQ", "TERMINAL"},
    {"LE", "TERMINAL"},
    {"GE", "TERMINAL"},
    {"NE", "TERMINAL"},
    {"ASSIGN", "TERMINAL"},
    {"NOT", "TERMINAL"},
    {"LT", "TERMINAL"},
    {"GT", "TERMINAL"},
    {"PLUS", "TERMINAL"},
    {"MINUS", "TERMINAL"},
    {"MUL", "TERMINAL"},
    {"DIV", "TERMINAL"},
    {"AND", "TERMINAL"},
    {"OR", "TERMINAL"},
    {"LP", "TERMINAL"},
    {"RP", "TERMINAL"},
    {"LB", "TERMINAL"},
    {"RB", "TERMINAL"},
    {"LC", "TERMINAL"},
    {"RC", "TERMINAL"},
    {"DOT","TERMINAL"},
    {"TYPE","CHAR"},
    {"CHAR","CHAR"},
    {"ID","CHAR"},
    {"FLOAT","FLOAT"},
    {"INT","INT"},
    {"Program", "NONTERMINAL"},
    {"ExtDefList", "NONTERMINAL"},
    {"ExtDef", "NONTERMINAL"},
    {"ExtDecList","NONTERMINAL"},
    {"Specifier", "NONTERMINAL"},
    {"StructSpecifier", "NONTERMINAL"},
    {"VarDec", "NONTERMINAL"},
    {"FunDec", "NONTERMINAL"},
    {"VarList", "NONTERMINAL"},
    {"ParamDec", "NONTERMINAL"},
    {"CompSt", "NONTERMINAL"},
    {"StmtList", "NONTERMINAL"},
    {"Stmt", "NONTERMINAL"},
    {"DefList", "NONTERMINAL"},
    {"Def", "NONTERMINAL"},
    {"DecList", "NONTERMINAL"},
    {"Dec", "NONTERMINAL"},
    {"Exp", "NONTERMINAL"},
    {"Args", "NONTERMINAL"},
    };

Node::Node(string node_name, int nodes_num, int line_num, ...) : name(node_name), nodes_num(nodes_num), line_num(line_num)
{
    va_list childnodes;
    va_start(childnodes, line_num);
    for (int i = 0; i < nodes_num; i++)
    {
        Node *node = (Node *)va_arg(childnodes, Node *);
        this->com_node.push(node);
    }
    va_end(childnodes);
}

Node::Node(string node_name, char *char_value):name(node_name)
{   
    this->char_value = new char[100];
    memcpy(this->char_value, char_value, strlen(char_value));
}

Node::Node(string node_name) : name(node_name)
{
}

Node::Node(string node_name, int int_value) : name(node_name), int_value(int_value)
{
}

Node::Node(string node_name, float float_value) : name(node_name), float_value(float_value)
{
}

void printTree(Node *root, int space)
{   
    
    print(root,space);
    int nodes_num = root->nodes_num;
    queue<Node *> nodes_queue = root->com_node;
    for (int i = 0; i < nodes_num; i++)
    {
        Node *node = nodes_queue.front();
        printTree(node, space + 2);
        nodes_queue.pop();
    }
}

void print(Node *node, int space)
{   
    string print_type=nameToCategory[node->name];
    if(node->nodes_num == 0 && print_type == "NONTERMINAL"){
        return;
    }

    for (int i = 0; i < space; i++)
    {
        printf(" ");
    }
    
    if (print_type=="NONTERMINAL"){
        std::cout << node->name <<" (" << node->line_num << ")" <<std::endl;
    }
    else if (print_type=="CHAR")
    {
        std::cout << node->name <<": " << node->char_value <<std::endl;
    }
    else if (print_type=="INT")
    {
        std::cout << node->name <<": " << node->int_value <<std::endl;
    }
    else if (print_type=="FLOAT"){
        std::cout << node->name <<": " << node->float_value <<std::endl;
    }
    else if (print_type=="TERMINAL"){
        std::cout << node->name <<std::endl;
    }    
}