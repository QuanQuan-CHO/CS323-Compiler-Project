#include <iostream>
#include <unordered_map>
#include <queue>
#include <stdarg.h>
#include <string.h>
using namespace std;

enum errtype{
    varnodef,       // a variable is used without a definition
    funnodef,       // a function is invoked without a definition
    varredef,       // a variable is redefined in the same scope
    funredef,       // a function is redefined
    equnmatch,      // unmatching types appear at both sides of the assignment operator (=)
    rvalleft,       // rvalue appears on the left-hand side of the assignment operator
    opunmatch,      // unmatching operands, such as adding an integer to a structure variable
    returnunmatch,  // a function’s return value type mismatches the declared type
    argunmatch,     // a function’s arguments mismatch the declared parameters (either types or numbers, or both)
    notanarr,       //applying indexing operator ([…]) on non-array type variables
    notafun,        //applying function invocation operator (foo(…)) on non-function names
    indexnoint,     //array indexing with a non-integer type expression
    dotnostuct,     //accessing members of a non-structure variable (i.e., misuse the dot operator)
    structnohas,    //accessing an undefined structure member
    structredef     //redefine the same structure type
};

enum type{
    intval,
    charval,
    floatval,
    fun,
    arr,
    biop,
    siop,
    intvar,
    floatvar,
    charvar,
    structvar,
    var,
    noact
};

enum act{
    ussiop,
    usbiop,
    usassign,
    checkreturn,
};

class rec;
class map{
    public:
    map* outmap;
    std::unordered_map<std::string, rec*> checkMap;
};
class Arr;
class Stru;
class Fun;
class rec{
public:
   type t;
   int line_num;
   string name;
   rec* val=nullptr;
   vector<rec*> recs;
   explicit rec(type nodetype, int line_num);
   explicit rec(type t,char* name);
   explicit rec(type t);
   explicit rec();
   explicit rec(const rec& other);
   void link(int nodes_num, ...);
   
};
rec* find(string name, map m);
void eq(rec* first, rec* second,act a, map m);
void buildarr (rec* id, rec* len);
void def (rec* type, rec* node, map m);
void err(errtype e, rec* r,int err=0);
bool check(const rec& first, const rec& second);
rec* usarr(rec* arr,rec* index, map m);
rec* usfun(rec* fun,rec* args,map m);
rec* usstruct(rec* stru, rec* mem,map m);
// void usfun(rec* id,rec* args);
// void usfun(rec* id);
// void usarr(rec* id,rec* index);
// void usstruct(rec*id,rec* mem);
// void set_type(type t,queue<rec*> recs);

