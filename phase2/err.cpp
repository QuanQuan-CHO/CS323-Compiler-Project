  #include "err.hpp"
   void argerr(errtype e,int line,int exp,int actual){
     if (e==argunmatch)
        {
            cout<<"Error type 9 at Line "<<line<<": invalid argument number, except "<<exp<<", got "<<actual<<endl;
        }
   }
   void error(errtype e,int line,char* id){
        if (e==varnodef){
            cout<<"Error type 1 at Line "<<line<<": "<<id<<" is used without a definition"<<endl;
        }else if (e==funnodef){
            cout<<"Error type 2 at Line "<<line<<": "<<id<<" is invoked without a definition"<<endl;
        }else if (e==varredef){
            cout<<"Error type 3 at Line "<<line<<": "<<id<<" is redefined in the same scope"<<endl;
        }else if (e==funredef)
        {
            cout<<"Error type 4 at Line "<<line<<": "<<id<<" is redefined"<<endl;
        }else if (e==equnmatch)
        {
            cout<<"Error type 5 at Line "<<line<<": unmatching types appear at both sides of the assignment operator"<<endl;
        }else if (e==rvalleft)
        {
            cout<<"Error type 6 at Line "<<line<<": rvalue appears on the left-hand side of the assignment operator"<<endl;
        }else if (e==opunmatch)
        {
            cout<<"Error type 7 at Line "<<line<<": unmatching operand"<<endl;
        }else if (e==returnunmatch)
        {
            cout<<"Error type 8 at Line "<<line<<": incompatiable return type"<<endl;
        }else if (err==noT&&kind==arr)
        {
            cout<<"Error type 10 at Line "<<line<<": applying indexing operator ([…]) on non-array type variables"<<endl;
        }else if (err==noT&&kind==fun)
        {
            cout<<"Error type 11 at Line "<<line<<": applying function invocation operator (foo(…)) on non-function names"<<endl;
        }else if (err==noT&&kind==index)
        {
            cout<<"Error type 12 at Line "<<line<<": array indexing with a non-integer type expression"<<endl;
        }else if (err==noT&&kind==strucT)
        {
            cout<<"Error type 13 at Line "<<line<<": accessing members of a non-structure variable"<<endl;
        }else if (err==nohas&&kind==strucT)
        {
            cout<<"Error type 14 at Line "<<line<<": accessing an undefined structure member"<<endl;
        }else if (err==redef&&kind==strucT)
        {
            cout<<"Error type 15 at Line "<<line<<": redefine the same structure type"<<endl;
        } else{
            cout<<"Error type 16 at Line "<<line<<": err"<<endl;
        }
     }
   
   