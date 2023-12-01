#include"Matrix.h"
#include<stdio.h>
#include<string.h>
#include<math.h>
#include<xmmintrin.h>
#include<immintrin.h>
#include<stdlib.h>
#include<omp.h>
#include<memory.h>

#define CheckMatrixMultiplication if (!checkAvailable(mtx1) || !checkAvailable(mtx2)){\
        printf("Matrix not available! And an error-type matrix will be returned.\n");\
    }\
    if (mtx1->m!=mtx2->n){\
        printf("Multiplication illegal! And an error-type matrix will be returned.\n");\
    }

int checkAvailable(const Matrix *mtx){
    if (mtx==NULL) return 0;
    if (mtx->n<1 || mtx->m<1) return 0;
    if (mtx->num==NULL) return 0;
    return 1;
}

Matrix* createMatrix(const size_t N,const size_t M){
    Matrix *mtx=(Matrix*)malloc(sizeof(Matrix));
    if (mtx){
        mtx->n=N;mtx->m=M;
        mtx->num=(double*)malloc(N*M*sizeof(double));
        for (int i=0;i<N;i++)
            for (int j=0;j<M;j++)
                mtx->num[i*mtx->m+j]=0;
    }
    return mtx;
}

void printMatrix(const Matrix *mtx){
    if (!checkAvailable(mtx)) printf("Matrix not available!\n");
    else for (int i=0;i<mtx->n;i++){
        for (int j=0;j<mtx->m;j++) printf("%0.2f ",mtx->num[i*mtx->m+j]);
        printf("\n");
    }
}

void fprintMatrix(FILE *fp,const Matrix *mtx){
    if (!checkAvailable(mtx)) fprintf(fp,"Matrix not available!\n");
    else for (int i=0;i<mtx->n;i++){
        for (int j=0;j<mtx->m;j++) fprintf(fp,"%0.2f ",mtx->num[i*mtx->m+j]);
        fprintf(fp,"\n");
    }
}

void deleteMatrix(Matrix *mtx){
    if (mtx==NULL) return;
    if (mtx->num!=NULL) free(mtx->num);
    mtx->num=NULL;
    free(mtx);
    mtx=NULL;
}

Matrix* matmul_plain(const Matrix *mtx1,const Matrix *mtx2){
    CheckMatrixMultiplication
    Matrix* ans=createMatrix(mtx1->n,mtx2->m);
    for (int i=0;i<ans->n;i++)
        for (int j=0;j<ans->m;j++)
            for (int k=0;k<mtx1->m;k++)
                ans->num[i*ans->m+j]+=mtx1->num[i*mtx1->m+k]*mtx2->num[k*mtx2->m+j];
    return ans;
}

Matrix* matmul_changeSequence(const Matrix *mtx1,const Matrix *mtx2){
    CheckMatrixMultiplication
    Matrix* ans=createMatrix(mtx1->n,mtx2->m);
    for (int i=0;i<ans->n;i++)
        for (int k=0;k<mtx1->m;k++){
            double tmp=mtx1->num[i*mtx1->m+k];
            for (int j=0;j<ans->m;j++) ans->num[i*ans->m+j]+=tmp*mtx2->num[k*mtx2->m+j];
        }
    return ans;
}

Matrix* matmul_OpenMP(const Matrix *mtx1,const Matrix *mtx2){
#pragma omp parallel for schedule(dynamic)
    CheckMatrixMultiplication
    Matrix* ans=createMatrix(mtx1->n,mtx2->m);
    for (int i=0;i<ans->n;i++)
        for (int k=0;k<mtx1->m;k++){
            double tmp=mtx1->num[i*mtx1->m+k];
            for (int j=0;j<ans->m;j++) ans->num[i*ans->m+j]+=tmp*mtx2->num[k*mtx2->m+j];
        }
    return ans;
}

void RecursiveStrassen(double* matA, double* matB, double* matC, const int M, const int N, const int K){
	if ((M <= 2) || M%2 != 0 || N%2 != 0 || K%2!=0)
	{
		for (int i = 0; i < M;i++){
		    for (int j = 0; j < N;j++){
			    double sum = 0.0;
			    for (int k = 0; k < K;k++) sum += matA[i*K + k] * matB[k*N + j];
			    matC[i*N + j] = sum;
		    }
	    }
        return;
	}

	int offset = 0;
	//M1 = (A11+A22)*(B11+B22)
	double* M1 = (double*) malloc((M/2) * (N/2) * sizeof(double));
	{
		//M1_0 = (A11+A22)
		double * M1_0 = (double*) malloc((M/2) * (K/2) * sizeof(double));
		offset = M*K / 2 + K / 2;
		for (int i = 0; i < M / 2; i++)
		{
			for (int j = 0; j < K/2; j++)
			{
				const int baseIdx = i*K + j;
				M1_0[i*K/2+j] = matA[baseIdx] + matA[baseIdx + offset];
			}
		}
		//M1_1 = (B11+B22)
		double* M1_1 = (double*) malloc((K/2) * (N/2) * sizeof(double));
		offset = K*N / 2 + N / 2;
		for (int i = 0; i < K / 2; i++)
		{
			for (int j = 0; j < N / 2; j++)
			{
				const int baseIdx = i*N + j;
				M1_1[i*N/2+j] = matB[baseIdx] + matB[baseIdx + offset];
			}
		}
		RecursiveStrassen(&M1_0[0], &M1_1[0], &M1[0], M / 2, N / 2, K / 2);

		free(M1_0);         M1_0=NULL;
		free(M1_1);         M1_1=NULL;
	}

	//M2 = (A21+A22)*B11
	double* M2 = (double*) malloc((M/2) * (N/2) * sizeof(double));
	{
		//M2_0 = (A21+A22)
		double* M2_0 = (double*) malloc((M/2) * (K/2) * sizeof(double));
		offset = K / 2;
		for (int i = M / 2; i < M; i++)
		{
			for (int j = 0; j < K / 2; j++)
			{
				const int baseIdx = i*K + j;
				M2_0[(i-M/2)*K/2+j] = matA[baseIdx] + matA[baseIdx + offset];
			}
		}
		//M2_1 = B11
        double* M2_1 = (double*) malloc((K/2) * (N/2) * sizeof(double));
        for(int i = 0; i < K / 2; i++) {
            for(int j = 0; j < N / 2; j++){
                M2_1[i * N/2 + j] = matB[i * N + j];
            }
        }
		RecursiveStrassen(&M2_0[0], &M2_1[0], &M2[0], M / 2, N / 2, K / 2);

		free(M2_0);         M2_0=NULL;
		free(M2_1);         M2_1=NULL;
	}

	//M3 = A11*(B12-B22)
	double* M3 = (double*) malloc((M/2) * (N/2) * sizeof(double));
	{
		//M3_0 = A11
		double* M3_0 = (double*) malloc((M/2) * (K/2) * sizeof(double));
		for(int i = 0; i < M / 2; i++){
            for(int j = 0; j < K / 2; j++){
                M3_0[i * K/2 + j] = matA[i * K + j];
            }
		}
		//M3_1 = (B12-B22)
		double* M3_1 = (double*) malloc((K/2) * (N/2) * sizeof(double));
		offset = K*N / 2;
		for (int i = 0; i < K/2; i++)
		{
			for (int j = N/2; j < N; j++)
			{
				const int baseIdx = i*N + j;
				M3_1[i*N/2+j-N/2] = matB[baseIdx] - matB[baseIdx + offset];
			}
		}
		RecursiveStrassen(&M3_0[0], &M3_1[0], &M3[0], M / 2, N / 2, K / 2);

		free(M3_0);         M3_0=NULL;
		free(M3_1);         M3_1=NULL;
	}

	//M4 = A22*(B21-B11)
	double* M4 = (double*) malloc((M/2) * (N/2) * sizeof(double));
	{
		//M4_0 = A22
		double* M4_0 = (double*) malloc((M/2) * (K/2) * sizeof(double));
		for(int i = M / 2; i < M; i++){
            for(int j = K / 2; j < K; j++){
                M4_0[(i-M/2) * K/2 + j - K/2] = matA[i * K + j];
            }
		}
		//M4_1 = (B21-B11)
		double* M4_1 = (double*) malloc((K/2) * (N/2) * sizeof(double));
		offset = N*K/2;
		for (int i = 0; i < K / 2; i++)
		{
			for (int j = 0; j < N/2; j++)
			{
				const int baseIdx = i*N + j;
				M4_1[i*N/2 + j] = matB[baseIdx + offset] - matB[baseIdx];
			}
		}
		RecursiveStrassen(&M4_0[0], &M4_1[0], &M4[0], M / 2, N / 2, K / 2);

		free(M4_0);         M4_0=NULL;
		free(M4_1);         M4_1=NULL;
	}

	//M5 = (A11+A12)*B22
	double* M5 = (double*) malloc((M/2) * (N/2) * sizeof(double));
	{
		//M5_0 = (A11+A12)
		double* M5_0 = (double*) malloc((M/2) * (K/2) * sizeof(double));
		offset = K / 2;
		for (int i = 0; i < M/2; i++)
		{
			for (int j = 0; j < K / 2; j++)
			{
				const int baseIdx = i*K + j;
				M5_0[i*K / 2 + j] = matA[baseIdx] + matA[baseIdx + offset];
			}
		}
		//M5_1 = B22
		double* M5_1 = (double*) malloc((K/2) * (N/2) * sizeof(double));
		offset = N*K/2 + N/2;
		for(int i = 0; i < K / 2; i++){
            for(int j = 0; j < N / 2; j++){
                M5_1[i * N/2 + j] = matB[i * N + j + offset];
            }
		}
		RecursiveStrassen(&M5_0[0], &M5_1[0], &M5[0], M / 2, N / 2, K / 2);

		free(M5_0);         M5_0=NULL;
		free(M5_1);         M5_1=NULL;
	}

	//M6 = (A21-A11)*(B11+B12)
	double* M6 = (double*) malloc((M/2) * (N/2) * sizeof(double));
	{
		//M6_0 = (A21-A11)
		double* M6_0 = (double*) malloc((M/2) * (K/2) * sizeof(double));
		offset = K * M / 2;
		for (int i = 0; i < M / 2; i++)
		{
			for (int j = 0; j < K/2; j++)
			{
				const int baseIdx = i*K + j;
				M6_0[i*K/2+j] = matA[baseIdx + offset] - matA[baseIdx];
			}
		}
		//M6_1 = (B11+B12)
		double* M6_1 = (double*) malloc((K/2) * (N/2) * sizeof(double));
		offset = N / 2;
		for (int i = 0; i < K / 2; i++)
		{
			for (int j = 0; j < N/2; j++)
			{
				const int baseIdx = i*N + j;
				M6_1[i*N/2+j] = matB[baseIdx] + matB[baseIdx + offset];
			}
		}
		RecursiveStrassen(&M6_0[0], &M6_1[0], &M6[0], M / 2, N / 2, K / 2);

		free(M6_0);         M6_0=NULL;
		free(M6_1);         M6_1=NULL;
	}

	//M7 = (A12-A22)*(B21+B22)
	double* M7 = (double*) malloc((M/2) * (N/2) * sizeof(double));
	{
		//M7_0 = (A12-A22)
		double* M7_0 = (double*) malloc((M/2) * (K/2) * sizeof(double));
		offset = M*K / 2;
		for (int i = 0; i < M / 2; i++)
		{
			for (int j = K/2; j < K; j++)
			{
				const int baseIdx = i*K + j;
				M7_0[i*K / 2 + j - K / 2] = matA[baseIdx] - matA[baseIdx + offset];
			}
		}
		//M7_1 = (B21+B22)
		double* M7_1 = (double*) malloc((K/2) * (N/2) * sizeof(double));
		offset = N / 2;
		for (int i = K/2; i < K; i++)
		{
			for (int j = 0; j < N / 2; j++)
			{
				const int baseIdx = i*N + j;
				M7_1[(i-K/2)*N / 2 + j] = matB[baseIdx] + matB[baseIdx + offset];
			}
		}
		RecursiveStrassen(&M7_0[0], &M7_1[0], &M7[0], M / 2, N / 2, K / 2);

		free(M7_0);         M7_0=NULL;
		free(M7_1);         M7_1=NULL;
	}

	for (int i = 0; i < M / 2;i++)
	{
		for (int j = 0; j < N / 2;j++)
		{
			const int idx = i*N / 2 + j;
			//C11 = M1+M4-M5+M7
			matC[i*N + j] = M1[idx] + M4[idx] - M5[idx] + M7[idx];
			//C12 = M3+M5
			matC[i*N + j + N/2] = M3[idx] + M5[idx];
			//C21 = M2+M4
			matC[(i+M/2)*N + j] = M2[idx] + M4[idx];
			//C22 = M1-M2+M3+M6
			matC[(i+M/2)*N + j + N/2] = M1[idx] - M2[idx] + M3[idx] + M6[idx];
		}
	}
	free(M1);           M1=NULL;
	free(M2);           M2=NULL;
	free(M3);           M3=NULL;
	free(M4);           M4=NULL;
	free(M5);           M5=NULL;
	free(M6);           M6=NULL;
	free(M7);           M7=NULL;
}
Matrix* matmul_Strassen(const Matrix* mtx1,const Matrix* mtx2){
    CheckMatrixMultiplication
    int n=mtx1->n,m=mtx2->m,k=mtx1->m;
    double *C=(double*)malloc(n*m*sizeof(double));
    RecursiveStrassen(mtx1->num,mtx2->num,C,n,m,k);
    Matrix* ans=createMatrix(n,m);
    for (int i=0;i<n;i++)
        for (int j=0;j<m;j++)
            ans->num[i*m+j]=C[i*m+j];
    free(C);
    C=NULL;
    return ans;
}

Matrix* matmul_SIMD(const Matrix* mtx1,const Matrix* mtx2){
    CheckMatrixMultiplication
    Matrix* c=createMatrix(mtx1->n,mtx2->m);
    int N=mtx1->n,M=mtx2->m,K=mtx1->m;
    double *ta[2];
    ta[0]=(double*)malloc(sizeof(double)*4*K);
    ta[1]=(double*)malloc(sizeof(double)*4*K);
    int i=0,j=0,k,t;
    do{
        k=0,i=0;
        do{
            ta[0][k]=mtx1->num[i*K+j];
            ta[1][k++]=mtx1->num[i*K+j+4];
            ta[0][k]=mtx1->num[i*K+j+1];
            ta[1][k++]=mtx1->num[i*K+j+5];
            ta[0][k]=mtx1->num[i*K+j+2];
            ta[1][k++]=mtx1->num[i*K+j+6];
            ta[0][k]=mtx1->num[i*K+j+3];
            ta[1][k++]=mtx1->num[i*K+j+7];
            i++;
        }while (i<K);
        i=0;
        do{
            __m256d t04_0,t04_1,t04_2,t04_3,t58_0,t58_1,t58_2,t58_3,
                a0,a1,b0,b1,b2,b3;
            t04_0=t04_1=t04_2=t04_3=t58_0=t58_1=t58_2=t58_3=_mm256_set1_pd(0);
            double *pb0=&mtx2->num[i*M],*pb1=&mtx2->num[(i+1)*M],*pb2=&mtx2->num[(i+2)*M],
                *pb3=&mtx2->num[(i+3)*M],*pa0=ta[0],*pa1=ta[1];
            double *endb0=pb1;
            do{
                a0=_mm256_loadu_pd(pa0);
                a1=_mm256_loadu_pd(pa1);
                b0=_mm256_set1_pd(*(pb0++));
                b1=_mm256_set1_pd(*(pb1++));
                b2=_mm256_set1_pd(*(pb2++));
                b3=_mm256_set1_pd(*(pb3++));
                t04_0+=a0*b0;
                t04_1+=a0*b1;
                t04_2+=a0*b2;
                t04_3+=a0*b3;
                t58_0+=a1*b0;
                t58_1+=a1*b1;
                t58_2+=a1*b2;
                t58_3+=a1*b3;
                pa0+=4;
                pa1+=4;
            }while(pb0!=endb0);
            _mm256_storeu_pd(&c->num[i*K+j],t04_0);
            _mm256_storeu_pd(&c->num[(i+1)*K+j],t04_1);
            _mm256_storeu_pd(&c->num[(i+2)*K+j],t04_2);
            _mm256_storeu_pd(&c->num[(i+3)*K+j],t04_3);
            _mm256_storeu_pd(&c->num[i*K+j+4],t58_0);
            _mm256_storeu_pd(&c->num[(i+1)*K+j+4],t58_1);
            _mm256_storeu_pd(&c->num[(i+2)*K+j+4],t58_2);
            _mm256_storeu_pd(&c->num[(i+3)*K+j+4],t58_3);
            i+=4;
        }while(i<M);
        j+=8;
    }while(j<N);
    free(ta[0]); ta[0]=NULL;
    free(ta[1]); ta[1]=NULL;
    return c;
}

void RecursiveWinograd(double* matA, double* matB, double* matC, const int M, const int N, const int K, const int strideA, const int strideB, const int strideC){
    if((M <= 2) || (M%2 != 0 || N%2 != 0 || K%2 != 0)){
        for(int i = 0; i < M; i++){
            for(int j = 0; j < N; j++){
                double sum = 0.0;
                for(int k = 0; k < K; k++) sum += matA[i*strideA + k] * matB[k*strideB + j];
                matC[i*strideC + j] = sum;
            }
        }
        return;
    }
    double* S1 = (double*) malloc((M/2) * (K/2) * sizeof(double));
    double* S2 = (double*) malloc((M/2) * (K/2) * sizeof(double));
    double* S3 = (double*) malloc((M/2) * (K/2) * sizeof(double));
    double* S4 = (double*) malloc((M/2) * (K/2) * sizeof(double));
        for(int i = 0; i < M/2; i++){
            for(int j = 0; j < K/2; j++){
                int idxA, offset, idxS = i * (K/2) + j;

                //S1     = A21 + A22
                idxA     = (i + (M/2)) * strideA + j;
                offset   = K/2;
                S1[idxS] = matA[idxA] + matA[idxA + offset];

                //S2     = S1 - A11
                idxA     = i * strideA + j;
                S2[idxS] = S1[idxS] - matA[idxA];

                //S3     = A11 - A21
                offset   = (M/2) * strideA;
                S3[idxS] = matA[idxA] - matA[idxA + offset];

                //S4     = A12 - S2
                idxA     = i * strideA + (K/2) + j;
                S4[idxS] = matA[idxA] - S2[idxS];
            }
        }
    

    double* T1 = (double*) malloc((K/2) * (N/2) * sizeof(double));
    double* T2 = (double*) malloc((K/2) * (N/2) * sizeof(double));
    double* T3 = (double*) malloc((K/2) * (N/2) * sizeof(double));
    double* T4 = (double*) malloc((K/2) * (N/2) * sizeof(double));
    
        for(int i = 0; i < K/2; i++){
            for(int j = 0; j < N/2; j++){
                int idxB, offset, idxT = i * (N/2) + j;

                //T1     = B12 - B11
                idxB     = i * strideB + j;
                offset   = (N/2);
                T1[idxT] = matB[idxB + offset] - matB[idxB];

                //T2     = B22 - T1
                idxB     = (i + (K/2)) * strideB + (N/2) + j;
                T2[idxT] = matB[idxB] - T1[idxT];

                //T3     = B22 - B12
                idxB     = i * strideB + (N/2) + j;
                offset   = ((K/2)) * strideB;
                T3[idxT] = matB[idxB + offset] - matB[idxB];

                //T4     = T2 - B21
                idxB     = (i + (K/2)) * strideB + j;
                T4[idxT] = T2[idxT] - matB[idxB];
            }
        }
    

    //M1 = A11 * B11
    double* M1 = (double*) malloc((M/2) * (N/2) * sizeof(double));
    RecursiveWinograd(matA, matB, &M1[0], M/2, N/2, K/2, strideA, strideB, N/2);

    //M2 = A12 * B21
    double* M2 = (double*) malloc((M/2) * (N/2) * sizeof(double));
    RecursiveWinograd(&matA[K/2], &matB[(K/2)*strideB], &M2[0], M/2, N/2, K/2, strideA, strideB, N/2);

    //M3 = S4 * B22
    double* M3 = (double*) malloc((M/2) * (N/2) * sizeof(double));
    RecursiveWinograd(&S4[0], &matB[(K/2) * strideB + (N/2)], &M3[0], M/2, N/2, K/2, K/2, strideB, N/2);

    //M4 = A22 * T4
    double* M4 = (double*) malloc((M/2) * (N/2) * sizeof(double));
    RecursiveWinograd(&matA[(M/2) * strideA + (K/2)], &T4[0], &M4[0], M/2, N/2, K/2, strideA, N/2, N/2);

    //M5 = S1 * T1
    double* M5 = (double*) malloc((M/2) * (N/2) * sizeof(double));
    RecursiveWinograd(&S1[0], &T1[0], &M5[0], M/2, N/2, K/2, K/2, N/2, N/2);

    //M6 = S2 * T2
    double* M6 = (double*) malloc((M/2) * (N/2) * sizeof(double));
    RecursiveWinograd(&S2[0], &T2[0], &M6[0], M/2, N/2, K/2, K/2, N/2, N/2);

    //M7 = S3 * T3
    double* M7 = (double*) malloc((M/2) * (N/2) * sizeof(double));
    RecursiveWinograd(&S3[0], &T3[0], &M7[0], M/2, N/2, K/2, K/2, N/2, N/2);

    //C11 = U1 = M1 + M2
    //C12 = U5 = U4 + M3 = U2 + M5 + M3 = M1 + M6 + M5 + M3
    //C21 = U6 = U3 - M4 = U2 + M7 - M4 = M1 + M6 + M7 - M4
    //C22 = U7 = U3 + M5 = U2 + M7 + M5 = M1 + M6 + M7 + M5
    for(int i = 0; i < M/2; i++){
        for(int j = 0; j < N/2; j++){
            int idx = i * (N/2) + j;
            matC[i*strideC + j] = M1[idx] + M2[idx];
            matC[i*strideC + j + (N/2)] = M1[idx] + M6[idx] + M5[idx] + M3[idx];
            matC[(i+(M/2))*strideC + j] = M1[idx] + M6[idx] + M7[idx] - M4[idx];
            matC[(i+(M/2))*strideC + j + (N/2)] = M1[idx] + M6[idx] + M7[idx] + M5[idx];
        }
    }
    free(S1);           S1=NULL;
    free(S2);           S2=NULL;
    free(S3);           S3=NULL;
    free(S4);           S4=NULL;
    free(T1);           T1=NULL;
    free(T2);           T2=NULL;
    free(T3);           T3=NULL;
    free(T4);           T4=NULL;
    free(M1);           M1=NULL;
    free(M2);           M2=NULL;
    free(M3);           M3=NULL;
    free(M4);           M4=NULL;
    free(M5);           M5=NULL;
    free(M6);           M6=NULL;
    free(M7);           M7=NULL;
}
Matrix* matmul_CoppersmithWinograd(const Matrix* mtx1,const Matrix* mtx2){
    CheckMatrixMultiplication
    int n=mtx1->n,m=mtx2->m,k=mtx1->m;
    double *C=(double*)malloc(n*m*sizeof(double));
    RecursiveWinograd(mtx1->num,mtx2->num,C,n,m,k,k,m,m);
    Matrix* ans=createMatrix(n,m);
    for (int i=0;i<n;i++)
        for (int j=0;j<m;j++)
            ans->num[i*m+j]=C[i*m+j];
    free(C);
    C=NULL;
    return ans;
}
