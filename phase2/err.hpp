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
void check_rval(rec r,errtype e);
void check_fun(rec r,errtype e);
void check_int(rec r,errtype e);
void check_arg(rec r,errtype e);
void check_arr(rec r,errtype e);
void check_struct(rec r,errtype e);
void check_struct_has(rec r,errtype e);

void check(rec r){
    if (r.a==defvar){
        check_redef(r,varredef);
    }else if (r.a==defstruct)
    {   
        check_redef(r,structredef);
    }else if (r.a==deffun)
    {
        check_redef(r,funredef);
        check_eqtype(r,returnunmatch);

    }else if (r.a==usassign)
    {   
    //    check_def(r,varnodef);
       check_eqtype(r,equnmatch);
       check_rval(r,rvalleft);
    }else if (r.a==usfun)
    {
    //    check_def(r,funnodef);
       check_fun(r,notafun);
       check_arg(r,argunmatch);
    }else if (r.a==usarr)
    {
        // check_def(r,varnodef);
        check_arr(r,notanarr);
        check_int(r,indexnoint);
    }else if (r.a==usstruct)
    {   
        // check_def(r,varnodef);
        check_struct(r,dotnostuct);
        check_struct_has(r,structnohas);
    }
    
    
    
}
class rec{
public:
   act a;
   queue<char*> ids;
   char* id;
   std::unordered_map<std::string, std::string> map;
};
