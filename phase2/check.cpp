#include "err.hpp"
std::unordered_map<std::string,std::string> initialmap={
    {"struct","struct"},
    {"int","int"},
    {"float","float"},
    {"char","char"},
    {"string","string"}
};
  std::unordered_map<std::string,std::string> createNewMap() {
    std::unordered_map<std::string,std::string> newMap;

    for (const auto& pair : initialmap) {
        newMap[pair.first] = pair.second;
    }

    return newMap;
}


// rec::rec(rec* r):t(r->t),line_num(r->line_num),name(r->name),recs(r->recs){};

// void check(rec r,std::unordered_map<char*,char*> map){
//     if (r.a==defvar){
//         check_redef(map, r,varredef);
//     }else if (r.a==defstruct)
//     {   
//         check_redef(map,r,structredef);
//     }else if (r.a==deffun)
//     {
//         check_redef(map,r,funredef);
//         check_eqtype(map,r,returnunmatch);
        
//     }else if (r.a==usassign)
//     {   
//     //    check_def(r,varnodef);
//        check_eqtype(map,r,equnmatch);
//        check_rval(map,r,rvalleft);
//     }else if (r.a==usfun)
//     {
//     //    check_def(r,funnodef);
//        check_fun(map,r,notafun);
//        check_arg(map,r,argunmatch);
//     }else if (r.a==usarr)
//     {
//         // check_def(r,varnodef);
//         check_arr(map,r,notanarr);
//         check_int(map,r,indexnoint);
//     }else if (r.a==usstruct)
//     {   
//         // check_def(r,varnodef);
//         check_struct(map,r,dotnostuct);
//         check_struct_has(map,r,structnohas);
//     }
// }