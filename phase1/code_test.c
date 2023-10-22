   #include "stdlib.h"
   #include "string.h"
   #include "stdio.h"

char* get_name_posi(const char* arg, int posi){
    char* name= (char *)malloc(50);
     if (name){
            sprintf(name, "%s (%d)\n",arg, posi);
        }
    return name;
}

char* get_name_val(const char* arg, const char* val){
    char* name= (char *)malloc(50);
     if (name){
            sprintf(name, "%s: %s\n",arg,val);
        }
    return name;
}

char* get_str6(const char* name, const char* str1,const char* str2,const char* str3,const char* str4,const char* str5){
    char* result = (char*)malloc(strlen(name)+strlen(str1) + strlen(str2) + strlen(str3) + strlen(str4) + strlen(str5) + 1);
    if(result){
    strcpy(result, name);  // Copy the first string
    strcat(result, str1);
    strcat(result, str2);  // Append the second string
    strcat(result, str3);  // Append the third string
    strcat(result, str4);
    strcat(result, str5);
    }
    else{
        printf("get_str6 fail");
    }

    return result;
}

char* get_str5(const char* name, const char* str1,const char* str2,const char* str3,const char* str4){
    char* result = (char*)malloc(strlen(name)+strlen(str1) + strlen(str2) + strlen(str3) + strlen(str4) + 1);
    if(result){
    strcpy(result, name);  // Copy the first string
    strcat(result, str1);
    strcat(result, str2);  // Append the second string
    strcat(result, str3);  // Append the third string
    strcat(result, str4);
    }
    else{
        printf("get_str5 fail");
    }
    
    return result;
}

char* get_str4(const char* name, const char* str1,const char* str2,const char* str3){
    char* result = (char*)malloc(strlen(name)+strlen(str1) + strlen(str2) + strlen(str3) + 1);
    if(result){
    strcpy(result, name);  // Copy the first string
    strcat(result, str1);
    strcat(result, str2);  // Append the second string
    strcat(result, str3);  // Append the third string
    }
    else{
        printf("get_str4 fail");
    }
    return result;
}
char* get_str3(const char* name, const char* str1,const char* str2){
    char* result = (char*)malloc(strlen(name)+strlen(str1) + strlen(str2) + 1);
    if(result){
    strcpy(result, name);  // Copy the first string
    strcat(result, str1);
    strcat(result, str2);  // Append the second string
    }
    else{
        printf("get_str3 fail");
    }
   
    return result;
}
char* get_str2(const char* name, const char* str1){
    char* result = (char*)malloc(strlen(name)+strlen(str1) + 1);
    if(result){  
    strcpy(result, name);  // Copy the first string
    strcat(result, str1);}
    else{
        printf("get_str2 fail");
        }
    return result;
}
int main(int argc, char **argv){
    char* name1=get_name_posi("Exp",1);
     char* str1=get_str2(name1,"exp_val\n");
     char* name3=get_name_posi("Args",2);
     char* str3=get_str2(name3,"args_val\n");
    char* name4=get_name_posi("ExtDef",3);
    char* str4=get_str2(name4,str1);
    char* name5=get_name_posi("ExtDecList",4);
    char* str5=get_str2(name5,str3);
    char* res=get_str2(str4,str5); 
    printf("%s",res);
}