#include <iostream>
#include <unordered_map>
#include <queue>
#include <stdarg.h>
#include <string.h>
using namespace std;

typedef enum errtype{
    varnodef,
    funnodef,
    varredef,
    funredef,
    equnmatch,
    rvalleft,
    opunmatch,
    returnunmatch,
    argunmatch,
    notanarr,
    notafun,
    indexnoint,
    dotnostuct,
    structnohas,
    structredef
} errtype;

typedef enum act{
    defvar,
    defstruct,
    deffun,
    usfun,
    usop,
    usassign,
    usarr,
    usstruct
} act;
void err(errtype e,int line,char* id="",int exp=0,int actual=0);
void check_redef (std::unordered_map<char*,char*> map, rec r,errtype e);
void check_def(std::unordered_map<char*,char*> map, rec r,errtype e);
void check_eqtype(std::unordered_map<char*,char*> map, rec r,errtype e);
void check_eqtype(std::unordered_map<char*,char*> map,rec r,errtype e);
void check_rval(std::unordered_map<char*,char*> map, rec r,errtype e);
void check_fun(std::unordered_map<char*,char*> map, rec r,errtype e);
void check_int(std::unordered_map<char*,char*> map,rec r,errtype e);
void check_arg(std::unordered_map<char*,char*> map, rec r,errtype e);
void check_arr(std::unordered_map<char*,char*> map, rec r,errtype e);
void check_struct(std::unordered_map<char*,char*> map, rec r,errtype e);
void check_struct_has(std::unordered_map<char*,char*> map, rec r,errtype e);
std::unordered_map<char*,char*> initialmap={
    {"struct","struct"},
    {"int","int"},
    {"float","float"},
    {"char","char"},
    {"string","string"}
};

std::unordered_map<char*, char*> createNewMap() {
    std::unordered_map<char*, char*> newMap;

    for (const auto& pair : initialmap) {
        newMap[pair.first] = pair.second;
    }

    return newMap;
}

class rec{
public:
   act a;
   queue<char*> ids;
   char* id;
   char* val;
   char* right;
   int line;
};
