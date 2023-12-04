#include"Matrix.h"
#include<stdio.h>
#include<string.h>
#include<math.h>
#include<stdlib.h>
#include<memory.h>

#ifndef _O3
#pragma GCC optimize(3)
#endif

#define CheckMatrixMultiplicationO3 if (!checkAvailable_O3(mtx1) || !checkAvailable_O3(mtx2)){\
        printf("Matrix not available! And an error-type matrix will be returned.\n");\
    }\
    if (mtx1->m!=mtx2->n){\
        printf("Multiplication illegal! And an error-type matrix will be returned.\n");\
    }


int checkAvailable_O3(const Matrix *mtx){
#ifndef _O3
    if (mtx==NULL) return 0;
    if (mtx->n<1 || mtx->m<1) return 0;
    if (mtx->num==NULL) return 0;
    return 1;
#else
    printf("O3 error in checking!\n");
    return 0;
#endif
}

Matrix* createMatrix_O3(const size_t N,const size_t M){
#ifndef _O3
    Matrix *mtx=(Matrix*)malloc(sizeof(Matrix));
    if (mtx){
        mtx->n=N;mtx->m=M;
        mtx->num=(double*)malloc(N*M*sizeof(double));
        for (int i=0;i<N;i++)
            for (int j=0;j<M;j++)
                mtx->num[i*mtx->m+j]=0;
    }
    return mtx;
#else
    printf("O3 error in creating matrix!\n");
    return createMatrix(N,M);
#endif
}

Matrix* matmul_O3(Matrix *mtx1,const Matrix *mtx2){
#ifndef _O3
    CheckMatrixMultiplicationO3
    Matrix* ans=createMatrix_O3(mtx1->n,mtx2->m);
    for (int i=0;i<ans->n;i++)
        for (int k=0;k<mtx1->m;k++){
            double tmp=mtx1->num[i*mtx1->m+k];
            for (int j=0;j<ans->m;j++) ans->num[i*ans->m+j]+=tmp*mtx2->num[k*mtx2->m+j];
        }
    return ans;
#else
    printf("O3 error and the first matrix will be returned.\n");
    return mtx1;
#endif
}