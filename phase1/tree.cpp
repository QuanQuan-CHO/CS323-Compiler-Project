#include "tree.hpp"
// 初始化映射
std::map<std::string, std::string> nameToCategory = {
        {"STRUCT", "TERMINAL"},
        {"if", "TERMINAL"},
        {"else", "TERMINAL"},
        {"while", "TERMINAL"},
        {"return", "TERMINAL"},
        {";", "TERMINAL"},
        {",", "TERMINAL"},
        {"==", "TERMINAL"},
        {"<=", "TERMINAL"},
        {">=", "TERMINAL"},
        {"!=", "TERMINAL"},
        {"=", "TERMINAL"},
        {"!", "TERMINAL"},
        {"<", "TERMINAL"},
        {">", "TERMINAL"},
        {"+", "TERMINAL"},
        {"-", "TERMINAL"},
        {"*", "TERMINAL"},
        {"/", "TERMINAL"},
        {"&&", "TERMINAL"},
        {"||", "TERMINAL"},
        {"(", "TERMINAL"},
        {")", "TERMINAL"},
        {"[", "TERMINAL"},
        {"]", "TERMINAL"},
        {"{", "TERMINAL"},
        {"}", "TERMINAL"},
        {".", "TERMINAL"},
        {"TYPE","VAL"},
        {"CHAR","VAL"},
        {"ID","VAL"},
        {}
    };

Node::Node(string node_name, int nodes_num, int line_num, ...) : name(node_name), nodes_num(0), line_num(0)
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
    printf("%s (%d)\n", root->name.c_str(), root->line_num);
    int nodes_num = root->nodes_num;
    queue<Node *> nodes_queue = root->com_node;
    for (int i = 0; i < nodes_num; i++)
    {
        Node *node = nodes_queue.front();
        print(node, space + 2);
        nodes_queue.pop();
    }
}

void print(Node *node, int space)
{
    if(node->nodes_num == 0 && node->nodetype == NONTERMINAL){
        return;
    }
    for (int i = 0; i < space; i++)
    {
        printf(" ");
    }
    switch (node->nodetype)
    {
    case Type:
    {
        printf("TYPE: %s\n", node->char_value);
        break;
    }
    case Int:
    {
        printf("INT: %s\n", node->name.c_str());
        break;
    }
    case Char:
    {
        printf("CHAR: %s\n", node->char_value);
        break;
    }
    case Float:
    {
        printf("FLOAT: %s\n", node->name.c_str());
        break;
    }
    case Id:
    {
        printf("ID: %s\n", node->char_value);
        break;
    }
    case TERMINAL:
    {
        printf("%s\n", node->name.c_str());
        break;
    }
    case NONTERMINAL:
    {
        printTree(node, space);
        break;
    }
    }
}