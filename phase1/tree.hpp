#ifndef NODE_HPP
#define NODE_HPP
#include <queue>
#include <string>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <map>
using namespace std;

class Node{
public:
//这个结点需要携带下一个点的值
//可能带位置，自己的值
    string name;
    union{
        int line_num;
        int int_value;
        char* char_value;
        float float_value;
    };
    int nodes_num = 0;
    queue<Node*> com_node;

    // 用于 bison
    explicit Node(string name, int nodes_num, int line_num, ...);

    // 用于 lex
    // 用于 TERMINAL (SEMI,etc....)
    explicit Node(string name);

    // 用于 CHAR, Id
    explicit Node(string name, char* char_value);

    // 用于INT
    explicit Node(string name, int int_value);

    // 用于 FLOAT
    explicit Node(string name, float float_value);        
};

void printTree(Node* root, int space=0);

// 在头文件中定义全局映射，并提前设定
extern std::map<std::string, std::string> nameToCategory;

#endif