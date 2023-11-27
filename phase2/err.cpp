  #include "err.hpp"





    
   void err(errtype e,int line,char* id="",int exp=0,int actual=0){
    if (e==varnodef){
            cout<<"Error type 1 at Line "<<line<<": "<<id<<" is used without a definition"<<endl;
        }else if (e==funnodef){
            cout<<"Error type 2 at Line "<<line<<": "<<id<<" is invoked without a definition"<<endl;
        }else if (e==varredef){
            cout<<"Error type 3 at Line "<<line<<": "<<id<<" is redefined in the same scope"<<endl;
        }else if (e==funredef)
        {
            cout<<"Error type 4 at Line "<<line<<": "<<id<<" is redefined"<<endl;
        }
        else if (e==equnmatch)
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
        }
        else if (e==argunmatch)
        {
            cout<<"Error type 9 at Line "<<line<<": invalid argument number, except "<<exp<<", got "<<actual<<endl;
            //can add a type check
        }
        else if (e==notanarr)
        {
            cout<<"Error type 10 at Line "<<line<<": indexing on non-array variable"<<endl;
        }else if (e==notafun)
        {
            cout<<"Error type 11 at Line "<<line<<": invoking non-function variable"<<endl;
        }else if (e==indexnoint)
        {
            cout<<"Error type 12 at Line "<<line<<": indexing by non-integer"<<endl;
        }else if (e==dotnostuct)
        {
            cout<<"Error type 13 at Line "<<line<<": accessing with non-struct variable"<<endl;
        }else if (e==structnohas)
        {
            cout<<"Error type 14 at Line "<<line<<": accessing an undefined structure member"<<endl;
        }else if (e=structredef)
        {
            cout<<"Error type 15 at Line "<<line<<": redefine the same structure type"<<endl;
        } else{
            cout<<"Error type 16 at Line "<<line<<": err"<<endl;
        }
     }
   
   