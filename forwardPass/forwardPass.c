#include <stdio.h>
#include <stdlib.h>
#include "nnlib.h"
#define SHAPE 2
int main()
{
    matrix *mat = create_matrix(2,2);
s    vector *vec = create_vector(2);
    vector *outVec = create_vector(2);

    DATA_TYPE arr[2] = { 2, 2};

    int i;
    for(i = 0; i < 4; i++)
    {
        mat->data[i/2][i%2] = i+2;
    }

    vec->data = arr;
    mat_print(mat);
    vec_print(vec);

    layer_pass(vec, mat, outVec);
    vec_print(outVec);
    relu(outVec);
    vec_print(outVec);


    free(vec);
    return 0;
}
