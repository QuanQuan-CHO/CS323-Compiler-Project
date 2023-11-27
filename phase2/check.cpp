#include "err.hpp"

void check_redef (std::unordered_map<char*,char*> map, rec r,errtype e){
    auto it = map.find(r.id);
    if (it != map.end()) {
        err(e,r.line);
    } else {
        map[r.id]=r.val;
    }
}
void check_eqtype(std::unordered_map<char*,char*> map,rec r,errtype e){
    auto it = map.find(r.id);
    if (it!=map.end())
    {
        char* ltype=it->second;
        char* rtype=r.right;
        if (rtype==nullptr)
    {   char* rside = r.ids.front();
        auto rtype = map.find(rside);}
    if (strcmp(ltype,rtype) == 0)
    {
        err(e,r.line);
    }
    }
    else{
        err(varnodef,r.line);
    }
    
}
void check(rec r,std::unordered_map<char*,char*> map){
    if (r.a==defvar){
        check_redef(map, r,varredef);
    }else if (r.a==defstruct)
    {   
        check_redef(map,r,structredef);
    }else if (r.a==deffun)
    {
        check_redef(map,r,funredef);
        check_eqtype(map,r,returnunmatch);
        
    }else if (r.a==usassign)
    {   
    //    check_def(r,varnodef);
       check_eqtype(map,r,equnmatch);
       check_rval(map,r,rvalleft);
    }else if (r.a==usfun)
    {
    //    check_def(r,funnodef);
       check_fun(map,r,notafun);
       check_arg(map,r,argunmatch);
    }else if (r.a==usarr)
    {
        // check_def(r,varnodef);
        check_arr(map,r,notanarr);
        check_int(map,r,indexnoint);
    }else if (r.a==usstruct)
    {   
        // check_def(r,varnodef);
        check_struct(map,r,dotnostuct);
        check_struct_has(map,r,structnohas);
    }
}