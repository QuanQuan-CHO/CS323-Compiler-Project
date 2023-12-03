  #include "err.hpp"
rec::rec(type nodetype, int line_num) : t(nodetype), line_num(line_num){
    // cout<<this->name<<endl;
}
rec::rec(type t):t(t){
};
rec::rec(type t,char* name):t(t),name(string(name)){
    
};
rec::rec(type t,string name):t(t),name(name){};
rec::rec(const rec& other) : t(other.t), line_num(other.line_num), name(other.name), val(nullptr) {
        if (other.val==&other)
        {   val=this;
            return;
        }
        
        // 复制 val
        if (other.val != nullptr) {
            val = new rec(*other.val);
        }

        // 复制 recs
        for (const auto& child : other.recs) {
            recs.push_back(new rec(*child));
        }
    }
rec::rec(){};
map m;

std::unordered_map<type, std::string> typeToStringMap = {
    {intval, "intval"},
    {charval, "charval"},
    {floatval, "floatval"},
    {fun, "fun"},
    {arr, "arr"},
    {biop, "biop"},
    {siop, "siop"},
    {struCt, "struCt"},
    {intvar, "intvar"},
    {floatvar, "floatvar"},
    {charvar, "charvar"},
    {structvar, "structvar"},
    {var, "var"},
    {def, "def"},
    {usfun, "usfun"},
    {ussiop, "ussiop"},
    {usbiop, "usbiop"},
    {usassign, "usassign"},
    {usarr, "usarr"},
    {usstruct, "usstruct"},
    {noact, "noact"},
    {deffun, "deffun"},
    {checkreturn, "checkreturn"}
};
string rec::toString() const{
    {   
        std::string result = "Type: " + typeToStringMap[t] + ", Line Number: " + std::to_string(line_num)
                            + ", Name: " + name ;
        if (this==val)
        { return result;
        }
        else{
        

        if (val != nullptr) {
            result += ", Value: (" + val->toString()+")";
        }

        result += " Child Nodes: [";
        for (const auto& subRec : recs) {
            result += subRec->toString() + ", ";
        }
        result += "]";
        return result;
        }
    }
}
rec* find(string name, map& m){    
        auto it = m.checkMap.find(name);
        if (it != m.checkMap.end()) {
            return it->second;
        } else {
            it = m.checkMap.find("fun "+name);
            if (it != m.checkMap.end()) {
            return it->second;
            }
        }return nullptr;
    }
void rec::link(int nodes_num, ...){
        va_list nodes;
        va_start(nodes, nodes_num);
        for (int i = 0; i < nodes_num; i++)
    {   rec *node = (rec *)va_arg(nodes, rec*);
        this->recs.push_back(node);
    }
    va_end(nodes);
    }
bool check (const rec& first, const rec& second) {
    // cout<<first.name<<endl<<second.name<<endl;
    // cout<<first.t<<endl<<second.t<<endl;
    if (&first==&second)
    {
       return true;
    }
    // cout<<(first.t==intvar||first.t==floatvar)<<(second.t==intvar||second.t==floatvar)<<endl;
    // if ((first.t==intvar||first.t==floatvar)&&(second.t==intvar||second.t==floatvar))
    // {
    //     return true;
    // } else 

    if (((first.t==second.t)&&(first.t!=structvar)))
    {   
       return true;
    }
    if (((first.t != second.t) || (first.name != second.name))) {
        return false;
    }
    // 比较 val
    if ((first.val == nullptr && second.val != nullptr) || (first.val != nullptr && second.val == nullptr)) {
        return false;
    }
    if (first.val != nullptr && second.val != nullptr && !check(*first.val, *second.val)) {
        return false;
    }
    // 比较 recs
    if (first.recs.size() != second.recs.size()) {
        return false;
    }
    for (size_t i = 0; i < first.recs.size(); ++i) {
        if (!check(*first.recs[i], *second.recs[i])) {
            return false;
        }
    }
    return true;
    }
rec* ac(rec* check){
for (rec* subRec : check->recs) {
     ac(subRec);
   }
    // cout<<typeToStringMap[check->t]<<endl;
    deal(check,m);
    return nullptr;
    }
void checkback(rec* fun,rec* Compst){
std::queue<rec*> bfsQueue;
        bfsQueue.push(Compst);  // 将根节点入队
        while (!bfsQueue.empty()) {
            rec* currentNode = bfsQueue.front();
            bfsQueue.pop();    
            if (currentNode->name=="Return")
            {  
                
               rec* re=currentNode->recs[0];
     
               if ((re->t==usbiop)||(re->t==usfun)||(re->t==usstruct))
                {   
                    if (!check(*re->val,*fun->val))
                    {
                    err(returnunmatch,re->val);
                    }
                    
                }
                else if (re->t==usarr)
                {   
                    // cout<<re->toString()<<endl;
                }
                
                else if (re->t==ussiop)
                {
                    if (!check(*re->recs[0],*fun->val))
                    {
                    err(returnunmatch,re->val);
                    }
                }
                
               else if (re->val==re)
               {
                if (!check(*re->val,*fun->val))
               {
                    err(returnunmatch,re);
               }
               }
               else{
                rec* r=find(re->name,m);
                if (!r)
                {
                   err(varnodef,re);
                }else{
                    if (!check(*r->val,*fun->val))
               {
                    err(returnunmatch,re);
               }
                }
               }
            }
            
            for (rec* subRec : currentNode->recs) {
                bfsQueue.push(subRec);
            }  
        }
}
void checktassign(rec* left,rec* right){
    // cout<<"我在赋值"<<endl;
    // cout<<left->toString()<<endl;
    // cout<<right->toString()<<endl;
    rec* l=find(left->name,m);
    if (!l)
    {
        if (left->val==left)
    {
       err(rvalleft,left);
       return;
    }   

       err(varnodef,left);
    }else{
        rec* r=find(right->name,m);
        if (right->val==right)
        {
            if (!check(*l->val,*right->val))
               {
                    err(equnmatch,left);
               }
        }
        else{
           
            if (!r)
        {   
            if (!check(*l->val,*right))
               {
                    err(varnodef,right);
               }
            
        }  else{
           
            if (!check(*l->val,*r->val))
               {
                    err(equnmatch,left);
               }
        }
        }
 
    }
    
}
rec* checkbiop(rec* left, rec* right){
    // cout<<"我在比较"<<endl;
    // cout<<left->toString()<<endl;
    // cout<<right->toString()<<endl;
    rec* l=find(left->name,m);
    if (!l&&left->val!=left)
    {  
       err(varnodef,left);
    }else{
        rec* r=find(right->name,m);
        if (right->val==right)
        {
            if (!check(*l->val,*right->val))
               {
                    err(opunmatch,left);
               }
        }else{
            if (!r)
        {  
            err(varnodef,right);
        }  else{
            if (!check(*l->val,*r->val))
               {
                    err(opunmatch,left);
               }
        }
        }
    }
    // if (right->val==right)
    // {  
    //    rec* res=new rec(*left);
    //    res->line_num=left->line_num;
    //    res->val=right;
    //    return res;
    // }
    
    return new rec(*right);
}
rec* checkusfun(rec* func,rec* args){
    
    rec* f=find(func->name,m);
    if (!f){
        err(funnodef,func);
    }else{
        if (f->t!=fun)
        {
            err(notafun,func);
            return nullptr;
        }
        
        if (!args&&f->recs.size()==0){
            rec* res=new rec(*f->val);
            res->line_num=func->line_num;
        return res;}
        else if (args&&f->recs.size()==0)
        {
           err(argunmatch,func,0,args->recs.size());
        }else if (f->recs.size()!=0&&!args)
        {
            err(argunmatch,func,f->recs[0]->recs.size(),0);
        }else{
            rec* fargs=f->recs[0];
            if (args->recs.size()!=fargs->recs.size()){
            err(argunmatch,func,f->recs[0]->recs.size(),args->recs.size());
            }
            for (rec* r:args->recs){    
            if (!find(r->name,m)&&r->val!=r)
            {
                err(varnodef,r);
            }
        }
        }
        rec* res=new rec(*f->val);
        res->line_num=func->line_num;
        return res;
        }
     return nullptr;
    }
rec* checkusstruct(rec* stru,rec* mem){
    //  cout<<stru->toString()<<endl;
    //  cout<<mem->toString()<<endl;
     rec* st=find(stru->name,m);
    if (!st){
        err(varnodef,st);
    }else{
        if(st->val->t!=structvar){
            err(dotnostuct,st);
        }else{
            rec* stname=st->val;//get apple
            rec* struc=stname->val;//get struct inside def
            rec* smem=stname->recs[0];//get link node
            for (rec* r:smem->recs)
            {   
                rec* m=r->recs[0];
                if (m->name==mem->name)
                {   
                    m->line_num=stru->line_num;
                    // cout<<"返回"<<endl;
                    // cout<<m->toString()<<endl;
                    return m;
                }
                
            }
            err(structnohas,mem);
        }
        
    }

    return nullptr;
}
rec* checkusarr(rec* arra, rec* index){
    // cout<<"___________"<<endl;
    // cout<<arra->toString()<<endl;
    //  cout<<"~~~~~~~~~~~~"<<endl;
     rec* res;
     if (arra->t!=arr)
     {
     rec* ar=find(arra->name,m);
    if (!ar){
        err(varnodef,arra);
    }else{
    if (ar->t!=arr)
    {
        err(notanarr,arra);
    }}
    res=new rec(*ar);
    res->recs.erase(res->recs.begin());
    }
    else if (arra->t==arr&&arra->recs.size()==0)
    {
        err(notanarr,arra);
        res=new rec(*arra);
        res->recs.erase(res->recs.begin());
    }else{
        res=new rec(*arra);
        res->recs.erase(res->recs.begin());
    }
    
    rec* ind=find(index->name,m);
    if (ind)
    {
        if (ind->val->t!=intvar)
        {
            err(indexnoint,index);
        }
    }else{
        if (index->t!=intvar)
        {
            err(indexnoint,index);
        }
    }
    res->line_num=arra->line_num;
    return res;
    }

rec* deal(rec* todeal, map& m){
  
    if (todeal->t==usstruct)
    {   
        rec* str=todeal->recs[0];
        rec* mem=todeal->recs[1]; 
        rec* s=str;
        rec* member=mem;
        if (s->t==usstruct)
        {
            s = find(s->val->name,m);
            
            if (!s)
            {
               err(varnodef,str);
            }else{
                s->line_num=str->line_num;
            }
        }else{
           
            s = find(s->name,m);
            
            if (!s)
            {
               err(varnodef,str);
            }else{
                s->line_num=str->line_num;
            }
        }
      
        todeal->val=checkusstruct(s,member);


    }
    if (todeal->t==checkreturn){
        rec* fun=todeal->recs[0];
        rec* Compst=todeal->recs[1];
        // cout<<"我放了一下结点进入函数返回检查"<<endl;
        // cout<<fun->toString()<<endl;
        // cout<<Compst->toString()<<endl;
        checkback(fun,Compst);
    }
    if (todeal->t==usassign){
        rec* left=todeal->recs[0];
        rec* right=todeal->recs[1];     
        rec* l=left;
        rec* r=right;  
        // cout<<"左边是"<<endl;
        // cout<<l->toString()<<endl;
        // cout<<"右边是"<<endl;
        // cout<<r->toString()<<endl;
        if ((left->t==usbiop)||(left->t==usfun)||(left->t==usstruct)||(left->t==usarr))
        {  
           
           l=left->val;
           if (left->val==nullptr)
          {  
             err(equnmatch,todeal);
             return nullptr;
          }
        }
        if ((right->t==usbiop)||(right->t==usfun)||(right->t==usstruct)||(right->t==usarr))
        {  
          if (right->val==nullptr)
          {
             return nullptr;
          }
           r=right->val;
        }
        checktassign(l,r);
        }
    if (todeal->t==usbiop)
    {   
        rec* left=todeal->recs[0];
        if (left->name=="Exp")
        {
           left=left->val;
        }
        
        rec* right=todeal->recs[2]; 
        todeal->val=checkbiop(left,right);

    }
    if (todeal->t==usfun)
    {   
        rec* fun=todeal->recs[0];
        rec* arg=nullptr; 
        if (todeal->recs.size()==2)
        {
            arg=todeal->recs[1]; 
        }
        todeal->val=checkusfun(fun,arg);
        // cout<<"goback"<<endl;
        // checkmap();
    }
    if (todeal->t==usarr)
    {   
        
        if (todeal->val!=nullptr)
        {
            return nullptr;
        }
        // cout<<todeal->toString()<<endl;
        rec* arr=todeal->recs[0];
        rec* index=todeal->recs[1];
        rec* d;
        if (arr->t==usarr)
        {   
            arr=arr->val;
        }
        if (index->t==usarr)
        {   
            index=index->val;
        }
        todeal->val= checkusarr(arr,index);
    }
    
    return nullptr;
}


void define (rec* type,rec* node){
    
    // cout<<type->t<<" "<<node->t<<endl;
    // cout<<"start to define"<<endl;
    // cout<<type->name<<endl;
    if (node->t==structvar){
        node->val=new rec(*type);
        auto it = m.checkMap.find(node->name);
        if (it != m.checkMap.end()) {
            err(structredef,node);
        } else {
            m.checkMap[node->name]=node;
        }
    }
    if (node->t==fun)
    {
        node->val=new rec(*type);
        auto it = m.checkMap.find("fun "+node->name);
        if (it != m.checkMap.end()) {
            err(funredef,node);
        } else {
            m.checkMap["fun "+node->name]=node;
        }
    
    }//如果是函数，其rec存的为输入参数，val表示其返回类型
    if (node->t==arr)
    {   
        node->val=new rec(*type);
        auto it = m.checkMap.find(node->name);
        if (it != m.checkMap.end()) {
            err(varredef,node);
        } else {
            m.checkMap[node->name]=node;
        }
        
    }//如果是数组，就把所有的成员值全部设为对应type
    if (node->t==var)
    {
        auto it = m.checkMap.find(node->name);
        rec* r=type;
        if (it != m.checkMap.end()) {
            err(varredef,node);
        } else {
            if (type->t==structvar&&type->val==nullptr)
            {   
                r=find(type->name,m);
                if (!r)
                {
                    err(varnodef,type);
                }
            }
            m.checkMap[node->name]=node;
            node->val=new rec(*r);
            // cout<<node->name<<endl;
            // cout<<node->val->name<<endl;
        }
    } //是变量值全设为对应type
    
    if (node->t==noact)
    {
       for (rec* element : node->recs) {
        define(type,element);
    }
    }//批量定义变量
    // checkmap();
}
void checkmap(){
    for (auto it = m.checkMap.begin(); it != m.checkMap.end(); ++it) {
        std::cout << "Key: " << it->first << ", Value: " << it->second << std::endl;}
    cout<<"finish define"<<endl;
}
void err(errtype e, rec* r,int exp,int err){
    if (e==varnodef){
            cout<<"Error type 1 at Line "<<r->line_num<<": "<<r->name<<" is used without a definition"<<endl;
        }else if (e==funnodef){
            cout<<"Error type 2 at Line "<<r->line_num<<": "<<r->name<<" is invoked without a definition"<<endl;
        }else if (e==varredef){
            cout<<"Error type 3 at Line "<<r->line_num<<": "<<r->name<<" is redefined in the same scope"<<endl;
        }else if (e==funredef)
        {
            cout<<"Error type 4 at Line "<<r->line_num<<": \""<< r->name << "\" is redefined" <<endl;
        }
        else if (e==equnmatch)
        {
            cout<<"Error type 5 at Line "<<r->line_num<<": unmatching types appear at both sides of the assignment operator"<<endl;
        }else if (e==rvalleft)
        {
            cout<<"Error type 6 at Line "<<r->line_num<<": rvalue appears on the left-hand side of the assignment operator"<<endl;
        }else if (e==opunmatch)
        {
            cout<<"Error type 7 at Line "<<r->line_num<<": unmatching operand"<<endl;
        }else if (e==returnunmatch)
        {
            cout<<"Error type 8 at Line "<<r->line_num<<": incompatiable return type \""<<r->name<<"\""<<endl;
        }
        else if (e==argunmatch)
        {
            cout<<"Error type 9 at Line "<<r->line_num<<": invalid argument number, except "<<exp<<", got "<<err<<endl;
            //can add a type check
        }
        else if (e==notanarr)
        {
            cout<<"Error type 10 at Line "<<r->line_num<<": indexing on non-array variable \""<<r->name<<"\""<<endl;
        }else if (e==notafun)
        {
            cout<<"Error type 11 at Line "<<r->line_num<<": invoking non-function variable \""<<r->name<<"\""<<endl;
        }else if (e==indexnoint)
        {
            cout<<"Error type 12 at Line "<<r->line_num<<": indexing by non-integer \""<<r->name<<"\""<<endl;
        }else if (e==dotnostuct)
        {
            cout<<"Error type 13 at Line "<<r->line_num<<": accessing with non-struct variable \""<<r->name<<"\""<<endl;
        }else if (e==structnohas)
        {
            cout<<"Error type 14 at Line "<<r->line_num<<": accessing an undefined structure member \""<<r->name<<"\""<<endl;
        }else if (e=structredef)
        {
            cout<<"Error type 15 at Line "<<r->line_num<<": redefine the same structure type \""<<r->name<<"\""<<endl;
        } 
        else if (e=argtype)
        {
            cout<<"Error type 16 at Line "<<r->line_num<<": unmatch args type \""<<r->name<<"\""<<endl;
        }
        else{
            cout<<"Error type 17 at Line "<<r->line_num<<": err"<<endl;
        }
     }
   
   