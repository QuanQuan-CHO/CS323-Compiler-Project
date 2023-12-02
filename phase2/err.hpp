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
    structredef,
    argtype
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
    charvar,//10
    structvar,
    var,
    def,
    usfun,
    ussiop,
    usbiop,
    usassign,
    usarr,
    usstruct,
    noact,
    deffun,
    checkreturn

};

class rec{
public:
   type t=noact;
   int line_num=0;
   string name="";
   rec* val=nullptr;
   vector<rec*> recs;
   void link(int nodes_num, ...);
   explicit rec(type nodetype, int line_num);
   explicit rec(type t,char* name);   
   explicit rec(type t,string name);//debug
   explicit rec(type t);
   explicit rec(const rec& other);//用于复制
   explicit rec();//用于生成数组中的成员
   std::string toString() const;
};
class map{
    public:
    map* outmap;
    std::unordered_map<std::string, rec*> checkMap;
};

rec* find(string name, map& m);
void buildarr(rec* id, rec* len);
rec* ac(rec* check);
rec* deal(rec* todeal,map& m);
void err(errtype e, rec* r,int err=0);
void define (rec* type,rec* id);
void checkmap();
// void usfun(rec* id,rec* args);
// void usfun(rec* id);
// void usarr(rec* id,rec* index);
// void usstruct(rec*id,rec* mem);
