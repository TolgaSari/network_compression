#include <stdio.h>
#include <stdlib.h>
#include "nnlib.h"

#define NR_END 1
#define BITS 4
#define WCOUNT 16

void relu(vector *vec)
{
    int j;
    for(j = 0; j < vec->len; j++)
    {
        RELU(vec->data[j]);
    }
}

void layer_pass(matrix* layer, vector* bias, vector* input, vector* output, float *qtable)
{
    int row, col;

    for (col = 0; col < layer->shape[1]; col++)// columns of layer matrix = output nodes
    {
        #ifdef QUANTIZED
            output->data[col] = qtable[(int)(bias->data[col])];// Add the bias first.
        #else
            output->data[col] = bias->data[col];// Add the bias first.
        #endif 


        for (row = 0; row < layer->shape[0]; row++)   // Rows of the layer matrix = input nodes
        {
            #ifdef QUANTIZED
                output->data[col] += input->data[row] * qtable[((int)layer->data[row][col])];
            #else
                output->data[col] += input->data[row] * layer->data[row][col];
            #endif 
        }
        //printf("%5d=%5f\n", col, output->data[col]);
    }
    relu(output);
    
}

int forward_pass(network *nn, vector* input)
{
    int x;
    int *shapes = malloc(nn->layer_count * sizeof(int));
    int prediction;
    vector *buffers = malloc((nn->layer_count + 1) * sizeof(vector));
    
    
    for(x = 0; x < nn->layer_count; x++)
    {
        buffers[x+1] = *create_vector(nn->layers[x].shape[1]);
    }
    
    //buffers[0] = *input;
    
    layer_pass(nn->layers, nn->biases, input, buffers + 1, nn->qtable);

    for(x = 1; x < nn->layer_count; x++)
    {
        layer_pass(nn->layers + x, nn->biases + x, buffers + x, buffers + x + 1, nn->qtable);
    }
    prediction = get_max(buffers + nn->layer_count);
    
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
        prediction = forward_pass(nn, &images[x]);
        if(prediction == (int)labels->data[x]) correct = correct + 1;
    }
    return (float) correct / (float) labels->len;
}

int get_max(vector *vec)
{
    int x;
    int max = 0;
    for(x = 0; x < vec->len; x++)
    {
        if(vec->data[max] <= vec->data[x])
        {
            max = x;
        }
    }
    return max;
}

void vector_print(vector * vec)
{
    int j;
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
        perror("read image Failed: ");
    }
    else
    {
        for (y = 0; y < sample_size; y++)
        {
            for (x = 0; x < image_size; x++)
            {
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

    //weight count
    int wcount = 16;
    // intervals between the weights will be distributed.
    float interval = 0.25;
    
    if(f == NULL)
    {
        perror("Failed: ");
        free(nn);
        nn = NULL;
    }
    else
    {
        fscanf(f, "%d", &layer_count);
        
        nn->layer_count = layer_count;
        printf("Layer count = %d\n", layer_count);
        nn->layers = malloc(layer_count * sizeof(matrix));
        nn->biases = malloc(layer_count * sizeof(vector));
        printf("\n");
        for(x = 0; x < layer_count; x++)
        {
            fscanf(f, "%d \n %d", &row, &col);
            nn->layers[x] = *create_matrix(row, col);
            nn->biases[x] = *create_vector(col);
            printf("%2d. layer = (%3d, %3d)\n", x,  nn->layers[x].shape[0],
                                                    nn->layers[x].shape[1]);
        }
        printf("\n");
        // Data is in form of:
        // layer_count, layer1_shape, layer2_shape ...
        // layer1_biases, layer1_weights, layer2_biases
        for(x = 0; x < layer_count; x++)
        {
            for(col = 0; col < nn->layers[x].shape[1]; col++)
            {
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
        fclose(f);
    }


    nn->qtable = malloc((wcount - 1) * sizeof(float));
    
    nn->qtable += wcount/2;
    
    for(x = -wcount/2 + 1; x < wcount/2; x++)
    {
        nn->qtable[x] = ((float) x) * interval / wcount * 2;
    }

    for(x = -wcount/2 + 1; x < wcount/2; x++)
    {
        printf("%2d = %f\n", x, nn->qtable[x]);
    }

    return nn;
}

void compress_zeros(char* file_name)
{
    char *comp_file_name = "comp_weights.txt"; 

    FILE *weight_file = fopen(file_name, "r");
    FILE *comp_file = fopen(comp_file_name, "w");
    FILE *skip_histogram = fopen("skip_histogram.txt", "w");
    int x, row, col, layer_count, zero_count;
    int skip_count[1024] = {0};
    network* nn = malloc(sizeof(network));
    matrix* new_layer;
    int read_data;
    int read_bytes;
    int total_skips;

    if(weight_file == NULL)
    {
        perror("compress_zeros weight file:");
    }
    else if(comp_file == NULL)
    {
        perror("compress_zeros comp file:");
    }
    else if(skip_histogram == NULL)
    {
        perror("compress_zeros skip_histogram file:");
    }
    else
    {
        fscanf(weight_file, "%d", &layer_count);
        
        nn->layer_count = layer_count;
        printf("Layer count = %d\n", layer_count);
        nn->layers = malloc(layer_count * sizeof(matrix));
        nn->biases = malloc(layer_count * sizeof(vector));
        printf("\n");
        for(x = 0; x < layer_count; x++)
        {
            fscanf(weight_file, "%d \n %d", &row, &col);
            nn->layers[x] = *create_matrix(row, col);
            nn->biases[x] = *create_vector(col);
            printf("%2d. layer = (%3d, %3d)\n", x,  nn->layers[x].shape[0],
                                                    nn->layers[x].shape[1]);
        }
        printf("\n");
        // Data is in form of:
        // layer_count, layer1_shape, layer2_shape ...
        // layer1_biases, layer1_weights, layer2_biases
        for(x = 0; x < layer_count; x++)
        {
            for(col = 0; col < nn->layers[x].shape[1]; col++)
            {
                read_bytes = fscanf(weight_file, "%d", &read_data);
                if(read_bytes == EOF)
                    break;
                nn->biases[x].data[col] = read_data;
                fprintf(comp_file, "%d\n", read_data);
            }
            
            for(row = 0; row < nn->layers[x].shape[0]; row++)
            {
                for (col = 0; col < nn->layers[x].shape[1]; col++)
                {
                    read_bytes = fscanf(weight_file, "%d", &read_data);
                    if(read_bytes == EOF)
                        break;
                    
                    if(read_data != 0)
                    {
                        nn->layers[x].data[row][col] = read_data;
                        fprintf(comp_file, "%d\n", read_data);
                    }
                    else
                    {
                        while(1)
                        {
                            zero_count++;
                            read_bytes = fscanf(weight_file, "%d", &read_data);
                            if(read_bytes == EOF)
                                break;
                            //if((zero_count + col == nn->layers[x].shape[1]))
                            //{
                                //skip_count[zero_count]++;
                                //col += zero_count;
                                //break;
                            //}  
                            //else if(read_data != 0)
                            if(read_data != 0)
                            {
                                total_skips += zero_count;
                                col += zero_count + 1;
                                break;
                            }
                        }

                        while(zero_count >= WCOUNT*WCOUNT-1)
                        {
                            zero_count -= WCOUNT*WCOUNT-1;
                            fprintf(comp_file,"%d\n",0);
                            fprintf(comp_file,"%d\n",0);
                            fprintf(comp_file,"%d\n",WCOUNT-1);
                            fprintf(comp_file,"%d\n",WCOUNT-1);
                            skip_count[WCOUNT-1]++;
                        }
                        while(zero_count >= WCOUNT-1)
                        {
                            fprintf(comp_file,"%d\n",0);
                            fprintf(comp_file,"%d\n",0);
                            fprintf(comp_file,"%d\n",zero_count & (WCOUNT - 1));
                            fprintf(comp_file,"%d\n",(zero_count >> BITS) & (WCOUNT - 1));
                            skip_count[WCOUNT-1]++;
                            zero_count = 0;
                        }
                        if(zero_count > 1)
                        {
                            fprintf(comp_file,"%d\n",0);
                            fprintf(comp_file,"%d\n",zero_count);
                            skip_count[zero_count > WCOUNT-1 ? WCOUNT-1 : zero_count]++;
                        }
                        else
                        {
                            fprintf(comp_file,"%d\n", -9);
                            skip_count[zero_count]++;
                        } 

                        fprintf(comp_file,"%d\n",read_data);
                        zero_count = 0;
                    }
                }
            }
        }

        fprintf(skip_histogram, "total skips = %5d\n", total_skips);
        for(x = 1; x < WCOUNT; x++)
        {
            fprintf(skip_histogram, "%5d skips = %5d\n", x, skip_count[x]);
        }

        fclose(weight_file);
        fclose(skip_histogram);
        fclose(comp_file);
    }
}

void network_print(network * nn)
{
    for(int x = 0; x < nn->layer_count; x++)
    {
        vector_print(nn->biases + x);
        matrix_print(nn->layers + x);
    }
}
