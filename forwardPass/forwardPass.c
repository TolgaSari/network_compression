#include <stdio.h>
#include <stdlib.h>
#include "nnlib.h"

#define SAMPLE_COUNT    10000
#define IMAGE_SIZE      784

int main()
{
    // Correctly labeled images
    float acc;
    // Allocate the image and labels matrixes.
    vector *images = create_vector_list(SAMPLE_COUNT, IMAGE_SIZE);
    vector *labels = create_vector_list(1, SAMPLE_COUNT);
    // Create the network based on the weights.
    network *nn = create_network("network_data/weights.txt");
    //network *nn = create_network("network_data/test_weights.txt");
    // Read the labels and the samples.
    //read_image("network_data/test_samples.txt", SAMPLE_COUNT, IMAGE_SIZE, images);
    read_image("network_data/mnist_samples.txt", SAMPLE_COUNT, IMAGE_SIZE, images);
    read_image("network_data/mnist_labels.txt", 1, SAMPLE_COUNT, labels);

    // Evaluate the network
    if(nn != NULL)
    {
        //network_print(nn);
        acc = evaluate(nn, images, labels);
    }

    printf("Accuracy of this network is: %5f\n", acc);
    
    free(images);
    free(labels);
    free(nn);
    
    return 0;
}
