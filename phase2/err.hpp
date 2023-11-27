#include <iostream>
#include <unordered_map>
#include <queue>
#include <stdarg.h>
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
    usvar,
    usfun,
    usop,
    usassign,
    usarr,
    usstruct
} act;
void err(errtype errt);
void check_redef (rec r,errtype e);
void check_def(rec r,errtype e);
void check_eqtype(rec r,errtype e);
void check_eqtype(rec r,errtype e);
void check(rec r){
    if (r.a==defvar){
        check_redef(r,varredef);
    }else if (r.a==defstruct)
    {   
        check_redef(r,structredef);
    }else if (r.a==deffun)
    {
        check_redef(r,funredef);
    }else if (r.a==usassign)
    {   
       check_def(r,varnodef);
       check_eqtype(r,equnmatch);
       
    }
}
class rec{
public:
   act a;
   queue<char*> ids;
   std::unordered_map<std::string, std::string> map;
};
