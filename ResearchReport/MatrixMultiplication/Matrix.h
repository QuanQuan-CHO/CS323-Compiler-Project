#ifndef MATRIX_H
#define MATRIX_H

#include<stdio.h>

const int Size[]={16,128,256,1000,2000,5000,6000,7000,8000,9000};
const int NumberofLittleData=5;
const int NumberofBigData=10;
typedef struct
{
    size_t n,m;
    double *num;
} Matrix;

Matrix* createMatrix(const size_t N,const size_t M);
Matrix* createMatrix_O3(const size_t N,const size_t M);
Matrix* createMatrixByInput(const size_t N,const size_t M,const double* const * Num);
void printMatrix(const Matrix *mtx);
void fprintMatrix(FILE *fp,const Matrix *mtx);
void deleteMatrix(Matrix* mtx);
Matrix* copyMatrix(const Matrix* mtx);
Matrix* matmul_plain(const Matrix* mtx1,const Matrix* mtx2);
Matrix* matmul_changeSequence(const Matrix* mtx1,const Matrix* mtx2);
Matrix* matmul_OpenMP(const Matrix *mtx1,const Matrix *mtx2);
Matrix* matmul_O3(Matrix *mtx1,const Matrix *mtx2);
Matrix* matmul_Strassen(const Matrix* mtx1,const Matrix* mtx2);
Matrix* matmul_SIMD(const Matrix* mtx1,const Matrix* mtx2);
Matrix* matmul_CoppersmithWinograd(const Matrix* mtx1,const Matrix* mtx2);

#endif