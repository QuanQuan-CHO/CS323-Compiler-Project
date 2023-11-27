  #include "symbol.hpp"

   string geterror(errtype err,int line){
        if (err==varnodef){
            cout<<"Error type 1 at Line "<<line<<": a variable is used without a definition"<<endl;
        }else if (err==funnodef){
            cout<<"Error type 2 at Line "<<line<<": a function is invoked without a definition"<<endl;
        }else if (err==varredef){
            cout<<"Error type 3 at Line "<<line<<": a variable is redefined in the same scope"<<endl;
        }else if (err==funredef)
        {
            cout<<"Error type 4 at Line "<<line<<": a function is redefined"<<endl;
        }else if (err==equnmatch)
        {
            cout<<"Error type 5 at Line "<<line<<": unmatching types appear at both sides of the assignment operator"<<endl;
        }else if (err==rvalleft)
        {
            cout<<"Error type 6 at Line "<<line<<": rvalue appears on the left-hand side of the assignment operator"<<endl;
        }else if (err==opunmatch)
        {
            cout<<"Error type 7 at Line "<<line<<": unmatching operands, such as adding an integer to a structure variable"<<endl;
        }else if (err==returnunmatch)
        {
            cout<<"Error type 8 at Line "<<line<<": a function’s return value type mismatches the declared type"<<endl;
        }else if (err==argunmatch)
        {
            cout<<"Error type 9 at Line "<<line<<": a function’s arguments mismatch the declared parameters"<<endl;
        }else if (err==notanarr)
        {
            cout<<"Error type 10 at Line "<<line<<": applying indexing operator ([…]) on non-array type variables"<<endl;
        }else if (err==notafun)
        {
            cout<<"Error type 11 at Line "<<line<<": applying function invocation operator (foo(…)) on non-function names"<<endl;
        }else if (err==indexnoint)
        {
            cout<<"Error type 12 at Line "<<line<<": array indexing with a non-integer type expression"<<endl;
        }else if (err==dotnostuct)
        {
            cout<<"Error type 13 at Line "<<line<<": accessing members of a non-structure variable"<<endl;
        }else if (err==structnohas)
        {
            cout<<"Error type 14 at Line "<<line<<": accessing an undefined structure member"<<endl;
        }else if (err==structredef)
        {
            cout<<"Error type 15 at Line "<<line<<": redefine the same structure type"<<endl;
        }
     }
   