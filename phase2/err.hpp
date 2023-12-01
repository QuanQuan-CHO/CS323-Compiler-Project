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
    struCt,
    intvar,
    floatvar,
    charvar,
    structvar,
    var,
};

enum act{
    def,
    usfun,
    ussiop,
    usbiop,
    usassign,
    usarr,
    usstruct,
    noact,
    deffun,
};
// void err(errtype e,int line,char* id="",int exp=0,int actual=0);
// void check_redef (std::unordered_map<char*,char*> map, rec r,errtype e);
// void check_def(std::unordered_map<char*,char*> map, rec r,errtype e);
// void check_eqtype(std::unordered_map<char*,char*> map, rec r,errtype e);
// void check_rval(std::unordered_map<char*,char*> map, rec r,errtype e);
// void check_fun(std::unordered_map<char*,char*> map, rec r,errtype e);
// void check_int(std::unordered_map<char*,char*> map,rec r,errtype e);
// void check_arg(std::unordered_map<char*,char*> map, rec r,errtype e);
// void check_arr(std::unordered_map<char*,char*> map, rec r,errtype e);
// void check_struct(std::unordered_map<char*,char*> map, rec r,errtype e);
// void check_struct_has(std::unordered_map<char*,char*> map, rec r,errtype e);

// class rec{
// public:
//    type t;
//    queue<rec*> recs;
//    int line_num;
//    string name;
//    act a;
//    rec* val;//val 不应该出现于rec而应该在返回值中
//    bool arr=false;
//    bool fun=false;
//    void link(int nodes_num, ...);
//    explicit rec(type nodetype, int line_num);
//    explicit rec(type t,char* name);
//    explicit rec(type t);
//    explicit rec(act a);
// };

class Arr;
class Stru;
class Fun;
class rec{
public:
   type t;
   int line_num;
   string name;
   act a;
   rec* val;
   queue<rec*> recs;
   void link(int nodes_num, ...);
   explicit rec(type nodetype, int line_num);
   explicit rec(type t,char* name);
   explicit rec(type t);
   explicit rec(act a);
};
void buildarr(rec* id, rec* len);
// void usfun(rec* id,rec* args);
// void usfun(rec* id);
// void usarr(rec* id,rec* index);
// void usstruct(rec*id,rec* mem);
// void set_type(type t,queue<rec*> recs);