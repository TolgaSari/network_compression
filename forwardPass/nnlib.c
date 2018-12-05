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

//    printf("\nInput:\n"); vector_print(input); NEWLINE
//    matrix_print(layer);
//    vector_print(bias);
    
    //printf("Matrix = (%3d, %3d), bias = %5d, input = %5d, output = %3d\n", layer->shape[0],
//           layer->shape[1], bias->len, input->len, output->len);
    
    for (x = 0; x < layer->shape[0]; x++)// columns of layer matrix = output nodes
    {
        output->data[x] = bias->data[x];// Add the bias first.
        
        for (y = 0; y < layer->shape[1]; y++)   // Rows of the layer matrix = input nodes
        {
            //printf("%d=%d\n",x,y);
            output->data[x] += input->data[y] * layer->data[x][y];
        }
    }
    //printf("%d\n",x);
//    printf("\nOutput:\n\n");vector_print(output);
    relu(output);
    //vector_print(output);
}

int forward_pass(network *nn, vector* input)
{
    int x;
    int *shapes = malloc(nn->layer_count * sizeof(int));
    int prediction;
    vector *buffers = malloc((nn->layer_count + 1) * sizeof(vector));
    
    
    for(x = 0; x < nn->layer_count; x++)
    {
        //shapes[2*x]   = nn->layers[x].shape[0];
        //shapes[2x+1] = nn->layers[x].shape[1];
//        printf("%2d. layer = (%3d, %3d)\n", x,  nn->layers[x].shape[0],
//                                                nn->layers[x].shape[1]);
        buffers[x+1] = *create_vector(nn->layers[x].shape[0]);
    }
    
    buffers[0] = *input;
    
    //vector_print(input);
    //printf("\n\n");
//    for(x = 0; x < nn->layer_count+1; x++)
//    {
//        printf("%2d. buffer size = %d\n", x, buffers[x].len);
//    }
    for(x = 0; x < nn->layer_count; x++)
    {
        layer_pass(nn->layers + x, nn->biases + x, buffers + x, buffers + x + 1);
        //vector_print(buffers + 1);
    }
    //printf("\n");
//    matrix_print(nn->layers + 2);
//    vector_print(nn->biases + 2);
    vector_print(buffers + 2);
//    vector_print(buffers + nn->layer_count);
    prediction = get_max(buffers + nn->layer_count);
    
    //printf("%d\n", prediction);
    
    free(buffers);
    
    return prediction;
}

float evaluate(network *nn, vector* images, vector* labels)
{
    int correct = 0;
    int x;
    int prediction;
    
    for(x = 0; x < labels->len; x++)
    {
        //vector_print(images + x);
        prediction = forward_pass(nn, &images[x]);
        //printf("prediction = %d, label = %d\n", prediction, (int) labels->data[x]);
        if(prediction == (int)labels->data[x]) correct = correct + 1;
    }
    printf("correct = %3d\n", correct);
    return (float) correct / (float) labels->len;
}

int get_max(vector *vec)
{
    int x;
    int max = 0;
    //vector_print(vec);
    for(x = 0; x < vec->len; x++)
    {
        if(vec->data[max] < vec->data[x])
        {
            max = x;
        }
    }
    //printf("max = %d\n",max);
    return max;
}

void vector_print(vector * vec)
{
    int j;
    //printf("Vector:\n\n");
    printf("| ");
    for(j = 0; j < vec->len; j++)
    {
        printf(PRINT_STR, vec->data[j]);
    }
    printf("|\n");
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

network* create_network(char* file_name)
{
    int layer_count;
    int x;
    int row, col;
    network* nn = malloc(sizeof(network));
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
        printf("\n");
        for(x = 0; x < layer_count; x++)
        {
            fscanf(f, "%d \n %d", &col, &row);
            nn->layers[x] = *create_matrix(row, col);
            nn->biases[x] = *create_vector(row);
            printf("%2d. layer = (%3d, %3d)\n", x,  nn->layers[x].shape[0],
                                                    nn->layers[x].shape[1]);
        }
        printf("\n");
        // Data is in form of:
        // layer_count, layer1_shape, layer2_shape ...
        // layer1_biases, layer1_weights, layer2_biases
        for(x = 0; x < layer_count; x++)
        {
            for(row = 0; row < nn->layers[x].shape[0]; row++)
            {

                fscanf(f, READ_STR, &read_data);
                nn->biases[x].data[row] = read_data;
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
    return nn;
}

void network_print(network * nn)
{
    for(int x = 0; x < nn->layer_count; x++)
    {
        vector_print(nn->biases + x);
        matrix_print(nn->layers + x);
    }
}
