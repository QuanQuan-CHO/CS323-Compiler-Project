  #include "errsave.hpp"
rec::rec(type t):t(t){};
rec::rec(type t,char* name):t(t),name(string(name)){};
rec::rec(){};
rec::rec(const rec& other) : t(other.t), line_num(other.line_num), name(other.name), val(nullptr) {
        if (this==&other)
        {
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
    // 如果以上条件都满足，说明两个对象是深度相等的
    
    return true;
    }
void def (rec* type, rec* node, map& m){
    // cout<<type->name<<" "<<node->name<<endl;
    // cout<<type->t<<" "<<node->t<<endl;
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
        auto it = m.checkMap.find(node->name);
        if (it != m.checkMap.end()) {
            err(funredef,node);
        } else {
            m.checkMap["fun "+node->name]=node;
        }
    }//如果是函数，其rec存的为输入参数，val表示其返回类型
    if (node->t==arr)
    {
        rec* rs=node->val;
        for (rec* element : rs->recs) {
        element->val=new rec(*type);
        element->t=type->t;
        }
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
        if (it != m.checkMap.end()) {
            err(varredef,node);
        } else {
            
            m.checkMap[node->name]=node;
            node->val=new rec(*type);
            // cout<<node->name<<endl;
            // cout<<node->val->name<<endl;
        }
    } //是变量值全设为对应type
    
    if (node->t==noact)
    {
       for (rec* element : node->recs) {
        def(type,element,m);
    }
    }//批量定义变量
    // cout<<"def finish"<<endl;
}
void rec:: link(int nodes_num, ...){
        va_list nodes;
        va_start(nodes, nodes_num);
        for (int i = 0; i < nodes_num; i++)
    {   
        rec *node = (rec *)va_arg(nodes, rec*);
        // cout<<node->name<<" "<<node->t<<endl;
            this->recs.push_back(node);
    }
    va_end(nodes);
    }
void buildarr(rec* id, rec* len){
    int intValue = std::stoi(len->name);
    for (int i = 0; i < intValue; i++)
    {
        id->recs.push_back(new rec());
    }
    
}
    rec* find(string name, map m){
        auto it = m.checkMap.find(name);
        if (it != m.checkMap.end()) {
            return it->second;
        } else {
            return nullptr;
        }
    }

void eq(rec* first,rec* second,act a,map m){
    // cout<<"eq start"<<endl;
    
    if (a==checkreturn){
        vector<rec*> recs=second->recs;
        for (const auto& rec : recs) {
            if (rec!=nullptr)
            {
                // cout<<rec->val->name<<endl;
                // cout<<rec->val->t<<endl;
                if (!check(*(first->val),*(rec->val)))
                {err(returnunmatch,rec);
                }         
            }
    }
    }
    if (a==usassign)
    {  
   
    // for (auto it = m.checkMap.begin(); it != m.checkMap.end(); ++it) {
    //     std::cout << "Key: " << it->first << ", Value: " << it->second << std::endl;
    // }
        
        if (first->t==var){
         if(!find(first->name,m)){
            err(varnodef,first);
         }
    }
    if (second->t==var){
         if(!find(second->name,m)){
            err(varnodef,second);
         }
    }
    
        if (first->val==first)
        {
            err(rvalleft,first);
            return;
        }
    
       if (!check(*(first->val),*(second->val)))
       {  
        // cout<<first->val->name<<" "<<second->name<<endl;
        // cout<<first->val->t<<" "<<second->t<<endl;
          err(equnmatch,first);
       }else{ 
            if (second->val=second)
            {
                first->val=second;
            }else{
                first->val=new rec(*(second->val));
            }
       }
      
    }
    if (a==usbiop)
    {   
        if (first->t==var){
         if(find(first->name,m)){
            err(varnodef,first);
         }
    }
    if (second->t==var){
         if(find(second->name,m)){
            err(varnodef,second);
         }
    }
       if (!check(*(first->val),*(second->val)))
       {
          err(opunmatch,first);
       }
    }
}
rec* usarr(rec* ar,rec* index=nullptr,map m={}){
    if (!(ar->t==arr))
    {
        err(notanarr,ar);
    }
    ar=find(ar->name,m);
    if (!ar)
    {
        err(varnodef,ar);
    }
    if (index->t!=intvar)
    {
        err(indexnoint,index);
    }
    string ind;
    if (index->val==index)
    {
        ind=index->name;
    }else {
        index=find(index->name,m);
        if(index){
            ind=index->val->val->name;
            int ex = std::stoi(ind);
            return ar->recs[ex];
        } else{
            err(varnodef,index);
        }
    }
    return nullptr;
}
rec* usstruct(rec* struC, rec* mem,map m){
    rec* stru=find(struC->name,m);
    if (!stru){
        err(varnodef,stru);
    }
    if (!(stru->val->t==structvar))
    {
        err(dotnostuct,stru);
    }
    //已命名的结构体中的val为struct类型，struct中的val存着一个连接结点，结点中存着成员有关信息
    rec* apple=stru->val;
    // cout<<"app"<<apple->t<<endl;
    // cout<<apple->name<<endl;
    rec* struc=apple->val;
    // cout<<"str"<<struc->t<<endl;
    // cout<<struc->name<<endl;
    rec* cone=struc->val;
    // cout<<"con"<<cone->t<<endl;
    // cout<<cone->name<<endl;
    vector<rec*> cons=cone->recs;
    for (const auto& con : cons) {
        vector<rec*> r=con->recs;
        for (const auto& value : r)
        {
            // cout<<value->t<<endl;
            // cout<<value->name<<endl;
        if (value->name==mem->name)
        {   value->line_num=mem->line_num;
            return value;
        }
        }
    }
    err(structnohas,mem);
        return nullptr;
}

rec* usfun(rec* func,rec* args,map m){
    if (!(func->t==fun))
    {
        err(notafun,func);
    }else if (!find("fun "+func->name,m))
    {
        err(funnodef,func);
    }else{
        if (func->recs.size()!=args->recs.size())
        {
            err(argunmatch,func,args->recs.size());
        } else {
            for (size_t i = 0; i < func->recs.size(); ++i) {
            if (check(*(func->recs[i]), *(args->recs[i])))
            {
                err(equnmatch,func);
            }
        }
        }
    }
    return new rec(*func->val);
}
void err(errtype e, rec* r,int err){
    if (e==varnodef){
            cout<<"Error type 1 at Line "<<r->line_num<<": "<<r->name<<" is used without a definition"<<endl;
        }else if (e==funnodef){
            cout<<"Error type 2 at Line "<<r->line_num<<": "<<r->name<<" is invoked without a definition"<<endl;
        }else if (e==varredef){
            cout<<"Error type 3 at Line "<<r->line_num<<": "<<r->name<<" is redefined in the same scope"<<endl;
        }else if (e==funredef)
        {
            cout<<"Error type 4 at Line "<<r->line_num<<": "<<r->name<<" is redefined"<<endl;
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
            cout<<"Error type 9 at Line "<<r->line_num<<": invalid argument number, except "<<r->recs.size()<<", got "<<err<<endl;
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
        } else{
            cout<<"Error type 16 at Line "<<r->line_num<<": err"<<endl;
        }
     }
   
   