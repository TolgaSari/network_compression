#include <stdio.h>
#include <stdlib.h>
#define DATA_TYPE int

#define RELU(x) x = x > 0 ? x : 0

typedef struct
{
    DATA_TYPE *data;
    int len;
} vector;

typedef struct
{
    DATA_TYPE **data;
    int shape[2];
} weight_matrix;

void relu(vector *vec);

int main()
{
    vector *vec = malloc(1 * sizeof(vector));
    DATA_TYPE arr[4] = { 0, 1, -1, -2};

    vec->data = arr;
    vec->len = 4;

    relu(vec);

    int k;
    for(k = 0; k < vec->len; k++)
    {
        printf(" %d", vec->data[k]);
    }
    printf("\n" );

    free(vec);
    return 0;
}

void relu(vector *vec)
{
    int j;
    for(j = 0; j < vec->len; j++)
    {
        RELU(vec->data[j]);
    }
}
