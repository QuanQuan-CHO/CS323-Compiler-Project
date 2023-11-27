#include <iostream>
    #include <unordered_map>
    using namespace std;
    unordered_map<string, string> Map;
     string geterror(int type,int line);
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