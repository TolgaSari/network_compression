#include <stdio.h>
#include <stdlib.h>
#include "nnlib.h"

#define SAMPLE_COUNT    1
#define IMAGE_SIZE      2

int main()
{
    // Correctly labeled images
    float acc;
    // Allocate the image and labels matrixes.
    vector *images = create_vector_list(SAMPLE_COUNT, IMAGE_SIZE);
    vector *labels = create_vector_list(1, SAMPLE_COUNT);
    // Create the network based on the weights.
    network *nn = create_network("network_data/test_weights.txt");
    // Read the labels and the samples.
    read_image("network_data/test_samples.txt", SAMPLE_COUNT, IMAGE_SIZE, images);
    read_image("network_data/mnist_labels.txt", 1, SAMPLE_COUNT, labels);
    // Evaluate the network
    
   // matrix_print(nn->layers + 0);
   // vector_print(images + 0);
    //vector_print(output);
    
    //printf("%d = lenght\n\n", images);
    
    //vector_print(labels);
    
    //forward_pass(nn, images);
//    void layer_pass(matrix* layer, vector* bias, vector* input, vector* output);
    
    //network_print(nn);
    
//    matrix* matt = create_matrix(2,2);
//    matt->data[0][0] = 1;
//    matt->data[0][1] = 2;
//    matt->data[1][0] = 3;
//    matt->data[1][1] = 4;
//
//    vector* vec = create_vector(2);
//    vec->data[0] = 1;
//    vec->data[1] = 1;
//
//    vector* vecc = create_vector(2);
//    vecc->data[0] = 1;
//    vecc->data[1] = 3;
//
//    vector *out = create_vector(2);
//    layer_pass(matt,vecc,vec,out);
//
//    get_max(out);
//
    if(nn != NULL)
    {
        network_print(nn);
        acc = evaluate(nn, images, labels);
    }

    //printf("Accuracy of this network is: %5f\n", acc);
    
    //vector_print(&nn->biases[2]);
    
    free(images);
    free(labels);
    free(nn);
    
    return 0;
}
