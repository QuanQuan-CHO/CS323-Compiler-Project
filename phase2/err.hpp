#include <iostream>
#include <unordered_map>
#include <queue>
#include <stdarg.h>
#include <string.h>
using namespace std;

enum errtype{
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
};

 enum type{
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
void err(errtype e,rec* r,int err=0);
bool check(const rec& first, const rec& second);
rec* usarr(rec* arr,rec* index, map m);
rec* usfun(rec* fun,rec* args,map m);
rec* usstruct(rec* stru, rec* mem,map m);
// void usfun(rec* id,rec* args);
// void usfun(rec* id);
// void usarr(rec* id,rec* index);
// void usstruct(rec*id,rec* mem);
// void set_type(type t,queue<rec*> recs);

