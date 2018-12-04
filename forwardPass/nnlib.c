#include <stdio.h>
#include <stdlib.h>
#include "nnlib.h"

#define NR_END 1

void relu(vector *vec)
{
    int j;
    for(j = 0; j < vec->len; j++)
    {
        RELU(vec->data[j]);
    }
}

void layer_pass(vector * inVec, matrix * mat, vector * outVec)
{
    int j,k;
    if(mat->shape[1] != inVec->len)
    {
        fprintf(stderr, "ERROR: Matrix and input vector's "
                        "dimensions dont match.\n");
    }
    if(mat->shape[0] != outVec->len)
    {
        fprintf(stderr, "ERROR: Matrix and output vector's "
                        "dimensions dont match.\n");
    }
    for (j = 0; j < outVec->len; j++)
    {
        outVec->data[j] = 0;
    }
    for(j = 0; j < mat->shape[0]; j++)
    {
        for(k = 0; k < mat->shape[1]; k++)
        {
            outVec->data[j] += mat->data[j][k] * inVec->data[k];
        }
    }
}

void vec_print(vector * vec)
{
    int j;
    printf("Vector:\n\n");
    printf("| ");
    for(j = 0; j < vec->len; j++)
    {
        
        printf(PRINT_STR, vec->data[j]);
    }
    printf("|\n\n");
}

void mat_print(matrix *mat)
{
    int j,k;
    printf("Matrix :\n\n");
    for(j = 0; j < mat->shape[0]; j++)
    {
        printf("| ");
        for (k = 0; k < mat->shape[1]; k++)
        {
            printf(PRINT_STR, mat->data[j][k]);
        }
        printf("| \n");
    }
    printf("\n");
}

double **dmatrix(int nrl, int nrh, int ncl, int nch)
/* allocate a double matrix with subscript range m[nrl..nrh][ncl..nch] */
{
	int i,nrow=nrh-nrl+1,ncol=nch-ncl+1;
	double **m;
	/* allocate pointers to rows */
	m=(double **) malloc((size_t)((nrow+NR_END)*sizeof(double*)));
	m += NR_END;
	m -= nrl;
	/* allocate rows and set pointers to them */
	m[nrl]=(double *) malloc((size_t)((nrow*ncol+NR_END)*sizeof(double)));
	m[nrl] += NR_END;
	m[nrl] -= ncl;
	for(i=nrl+1;i<=nrh;i++) m[i]=m[i-1]+ncol;
	/* return pointer to array of pointers to rows */
	return m;
}

matrix *create_matrix(int nrow, int ncol)
{
    int i;
    matrix *m = (matrix *) malloc(sizeof(matrix));
    m->shape[0] = nrow;
    m->shape[1] = ncol;
    DATA_TYPE **mat;
    mat = (DATA_TYPE**)malloc(nrow*sizeof(DATA_TYPE*));
    mat[0] = (DATA_TYPE*)malloc(nrow*ncol*sizeof(DATA_TYPE));
    for(i=1; i < nrow; i++) mat[i] = mat[i-1] + ncol;
    m->data  = mat;
    return m;
}

vector *create_vector(int len)
{
    vector *v = malloc(sizeof(vector));
    v->data = malloc(len * sizeof(DATA_TYPE));
    v->len = len;
    return v;
}

double *dvector(int nl, int nh)
/* allocate a double vector with subscript range v[nl..nh] */
{
	double *v;
	v=(double *)malloc((size_t) ((nh-nl+1+NR_END)*sizeof(double)));
	return v-nl+NR_END;
}

void read_image(char* file_name, int sample_size, int image_size, DATA_TYPE** image)
{
	FILE *f;
	f = fopen(file_name, "r");
	int x, y;
	int counter = 0;
    float pixel;
    if (f == NULL)
    {
        perror("Failed: ");
    }
    else
    {
        for (y = 0; y < sample_size; y++)
        {
            for (x = 0; x < image_size; x++)
            {
                //printf("%d",x);
                fscanf(f, "%f", &pixel); // For float
                image[y][x] = pixel;
            }
        }
        fclose(f);
    }
}

void create_network(char* file_name, network* nn)
{
    int layer_count;
    int x;
    
    matrix* new_layer;
    
    FILE *f = fopen(file_name, "r");
    
    if(f == NULL)
    {
        perror("Failed: ");
    }
    else
    {
        fscanf(f, "%d", &layer_count);
        
        nn->layer_count = layer_count;
        nn->layers = malloc(layer_count * sizeof(matrix));
        for(x = 0; x < layer_count; x++)
        {
            fscanf(f, "%d", &nn->layers[x].shape[0]);
            fscanf(f, "%d", &nn->layers[x].shape[1]);
            printf("%2d. layer = (%4d, %4d)\n", x,  nn->layers[x].shape[0],
                                                    nn->layers[x].shape[1]);
        }
        
        for(x = 0; x < layer_count; x++)
        {
            new_layer = &nn->layers[x];
        }
    }
}

void write_image(char* file_name, int im_row, int im_col, double**image)
{
	FILE *image_text;
	image_text = fopen(file_name, "w");
	int x, y;
	for (x = 1; x <= im_row; x++)
	{
		for (y = 1; y <= im_col; y++)
		{
			fprintf(image_text, "%d\n", (int)image[x][y]);
		}
	}
	fclose(image_text);
}
