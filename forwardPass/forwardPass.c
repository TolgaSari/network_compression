#include <stdio.h>
#include <stdlib.h>
#include "nnlib.h"

#define SAMPLE_COUNT    10000
#define IMAGE_SIZE      784

int main()
{
    // Allocate the image and labels matrixes.
    vector *images = create_vector_list(SAMPLE_COUNT, IMAGE_SIZE);
    vector *labels = create_vector_list(SAMPLE_COUNT, 1);
    // Network matrix
    network *nn = (network *) malloc(sizeof(network));
    // Read the labels and the samples.
    read_image("network_data/mnist_samples.txt", SAMPLE_COUNT, IMAGE_SIZE, images);
    read_image("network_data/mnist_labels.txt", SAMPLE_COUNT, 1, labels);
    // Create the network based on the weights.
    create_network("network_data/weights.txt", nn);
    // Evaluate the network
    vector *output = create_vector(10);
    layer_pass(nn->layers + 0, nn->biases + 0, images + 8, output);
    
   // matrix_print(nn->layers + 0);
   // vector_print(images + 0);
    vector_print(output);
    
    int x = 0;
    
    printf("%f\n", nn->layers[0].data[x++]);
    printf("%f\n", nn->layers[0].data[x++]);
    printf("%f\n", nn->layers[0].data[x++]);
    printf("%f\n", nn->biases[0].data[90]);
    printf("%f\n", nn->biases[1].data[0]);
    
	
    return 0;
}
