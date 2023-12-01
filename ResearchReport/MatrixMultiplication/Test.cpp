#include<iostream>
#include<cstdio>
#include<cblas.h>
#include<stdlib.h>
#include<cstring>
#include<unistd.h>
#include<chrono>
#include"Matrix.h"

using namespace std;

#define TIME_START start=std::chrono::steady_clock::now();
#define TIME_END(NAME) end=std::chrono::steady_clock::now();\
            duration=std::chrono::duration_cast<std::chrono::milliseconds>(end-start).count();\
            cout<<"  "<<NAME<<": finished in "<<duration<<" ms";
#define FPRINT(NAME) Path=Path1+(NAME)+Path2;\
            FileOut=fopen(Path.c_str(),"w+");\
            fprintMatrix(FileOut,ans);\
            Diff=Diff1+(NAME)+Diff2;\
            if (NAME=="Plain") cout<<endl;\
            else if (!system(Diff.c_str()))\
            cout<<" and the result is the same as Plain method."<<endl;\


Matrix *mtx1,*mtx2;
Matrix *ans;
FILE* FileOut;
string Path;
string Path1="out/",Path2=".out";
string Diff;
string Diff1="diff out/Plain.out out/",Diff2=".out";
void data(int n);
void test(int id,int n){
    printf("Testing case %d (N = %d):\n",id,n);
    data(n);
    auto start = std::chrono::steady_clock::now();
    auto end = std::chrono::steady_clock::now();
    auto duration = 0L;
    mtx1=createMatrix(n,n);
    for (int i=0;i<n;i++)
        for (int j=0;j<n;j++){
            double x;
            scanf("%lf",&x);
            mtx1->num[i*n+j]=x;
        }
    mtx2=createMatrix(n,n);
    for (int i=0;i<n;i++)
        for (int j=0;j<n;j++){
            double x;
            scanf("%lf",&x);
            mtx2->num[i*n+j]=x;
        }
    ans=createMatrix(n,n);
    if (n<=2000){
        TIME_START
        ans=matmul_plain(mtx1,mtx2);
        TIME_END("Plain")
        FPRINT("Plain")

        TIME_START
        ans=matmul_changeSequence(mtx1,mtx2);
        TIME_END("ChangeSequence")
        FPRINT("ChangeSequence")

        TIME_START
        ans=matmul_OpenMP(mtx1,mtx2);
        TIME_END("OpenMP")
        FPRINT("OpenMP")

        TIME_START
        ans=matmul_O3(mtx1,mtx2);
        TIME_END("O3")
        FPRINT("O3")

        TIME_START
        ans=matmul_SIMD(mtx1,mtx2);
        TIME_END("SIMD")
        FPRINT("SIMD")

        TIME_START
        ans=matmul_Strassen(mtx1,mtx2);
        TIME_END("Strassen")
        FPRINT("Strassen")

        TIME_START
        cblas_dgemm(CblasRowMajor,CblasNoTrans,CblasNoTrans,n,n,n,1.0,mtx1->num,n,mtx2->num,n,0.0,ans->num,n);
        TIME_END("OpenBLAS")
        FPRINT("OpenBLAS")

        TIME_START
        ans=matmul_CoppersmithWinograd(mtx1,mtx2);
        TIME_END("Winograd")
        FPRINT("Winograd")
    }
    else{
        TIME_START
        ans=matmul_SIMD(mtx1,mtx2);
        TIME_END("MyCode")
        printf("\n");
        // TIME_START
        // cblas_dgemm(CblasRowMajor,CblasNoTrans,CblasNoTrans,n,n,n,1.0,mtx1->num,n,mtx2->num,n,0.0,ans->num,n);
        // TIME_END("OpenBLAS")
        // printf("\n");
    }

    delete(mtx1);
    delete(mtx2);
    delete(ans);
}

void data(int size){
    auto start = std::chrono::steady_clock::now();
    auto end = std::chrono::steady_clock::now();
    FILE *fp=fopen("data.in","w+");
    printf("Begin generating data...\n");
    TIME_START
    for (int i=0;i<size;i++){
        for (int j=0;j<size;j++) fprintf(fp,"%d ",rand()%10);
        fprintf(fp,"\n");
    }
    
    for (int i=0;i<size;i++){
        for (int j=0;j<size;j++) fprintf(fp,"%d ",rand()%10);
        fprintf(fp,"\n");
    }

    fprintf(fp,"\n");
    printf("Generate data successfully.\n");
    fclose(fp);
}
int main(){
    srand((unsigned int)time(NULL));
    freopen("data.in","r",stdin);
    system("mkdir -p out");
    //for (int t=0;t<NumberofLittleData;t++) test(t,Size[t]);
    for (int t=NumberofLittleData;t<NumberofBigData;t++) test(t,Size[t]);
}
