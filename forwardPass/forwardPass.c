#include <stdio.h>
#include <stdlib.h>
#include "nnlib.h"
#define SHAPE 2
int main()
{
    // Allocate the image and labels matrixes.
    matrix *images = create_matrix(10000, 784);
    matrix *labels = create_matrix(10000, 1);
    // Network matrix
    network *nn = (network *) malloc(sizeof(network));
    // Read the labels and the samples.
    read_image("network_data/mnist_samples.txt", 10000, 784, images->data);
    read_image("network_data/mnist_labels.txt", 10000, 1, labels->data);
    
    printf("dude what \n");
    
    create_network("network_data/weights.txt", nn);
    int x = 0;
    
    printf("%f\n", nn->biases[0].data[x++]);
    printf("%f\n", nn->biases[0].data[x++]);
    printf("%f\n", nn->biases[0].data[x++]);
    printf("%f\n", nn->biases[0].data[x++]);
    printf("%f\n", nn->biases[0].data[x++]);
    
	
    return 0;
}
