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

void layer_pass(matrix* layer, vector* bias, vector* input, vector* output)
{
    int x, y;
    //matrix_print(layer);
    //vector_print(input);
    for (x = 0; x < layer->shape[1]; x++)// columns of layer matrix = output nodes
    {
        for (y = 0; y < layer->shape[0]; y++)// rows of the layer matrix = input nodes
        {
            output->data[x] += input->data[y] * layer->data[x][y];
        }
        output->data[x] += bias->data[x];
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

void vector_print(vector * vec)
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

void matrix_print(matrix *mat)
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

vector* create_vector_list(int count, int len)
{
    int x, y;
    vector* vec = malloc(count * sizeof(vector));
    
    for(x = 0; x < count; x++)
    {
        vec[x] = *create_vector(len);
    }
    
    return vec;
}

void read_image(char* file_name, int sample_size, int image_size, vector* images)
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
                images[y].data[x] = pixel;
            }
        }
        fclose(f);
    }
}

void create_network(char* file_name, network* nn)
{
    int layer_count;
    int x;
    int row, col;
    matrix* new_layer;
    
    FILE *f = fopen(file_name, "r");
    
    DATA_TYPE read_data;
    
    if(f == NULL)
    {
        perror("Failed: ");
    }
    else
    {
        fscanf(f, "%d", &layer_count);
        
        nn->layer_count = layer_count;
        nn->layers = malloc(layer_count * sizeof(matrix));
        nn->biases = malloc(layer_count * sizeof(vector));
        for(x = 0; x < layer_count; x++)
        {
            fscanf(f, "%d \n %d", &row, &col);
            nn->layers[x] = *create_matrix(row, col);
            nn->biases[x] = *create_vector(col);
            printf("%2d. layer = (%3d, %3d)\n", x,  nn->layers[x].shape[0],
                                                    nn->layers[x].shape[1]);
        }
        // Data is in form of:
        // layer_count, layer1_shape, layer2_shape ...
        // layer1_biases, layer1_weights, layer2_biases
        for(x = 0; x < layer_count; x++)
        {
            for(col = 0; col < nn->layers[x].shape[1]; col++)
            {
                printf("%d\n",col);
                fscanf(f, READ_STR, &read_data);
                nn->biases[x].data[col] = read_data;
            }
            
            for(row = 0; row < nn->layers[x].shape[0]; row++)
            {
                for (col = 0; col < nn->layers[x].shape[1]; col++)
                {
                    fscanf(f, READ_STR, &read_data);
                    nn->layers[x].data[row][col] = read_data;
                }
            }
        }
    }
}
