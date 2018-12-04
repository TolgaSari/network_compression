#include <stdio.h>
#include <stdlib.h>
#include "nnlib.h"
#define SHAPE 2
int main()
{
//    matrix *mat = create_matrix(2,2);
//    vector *vec = create_vector(2);
//    vector *outVec = create_vector(2);
//
//    DATA_TYPE arr[2] = { 2, 2};
//
//    int i;
//    for(i = 0; i < 4; i++)
//    {
//        mat->data[i/2][i%2] = i+2;
//    }
//
//    vec->data = arr;
//    mat_print(mat);
//    vec_print(vec);
//
//    layer_pass(vec, mat, outVec);
//    vec_print(outVec);
//    relu(outVec);
//    vec_print(outVec);
//

    matrix *images = create_matrix(10000, 784);
    read_image("mnist_samples.txt", 10000, 784, images->data);
//    matrix *images = create_matrix(1, 4);
//    read_image("test.txt", 1, 4, images->data);
    printf("%f %f %f %f",   images->data[1000][0], images->data[1000][290],
                            images->data[1000][270], images->data[1000][300]);

//    free(vec);

    return 0;
}
