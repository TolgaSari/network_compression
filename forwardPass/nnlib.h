#define DATA_TYPE int

#define RELU(x) x = x > 0 ? x : 0

typedef struct
{
    DATA_TYPE *data;
    int len;
} vector;

typedef struct
{
    int *shape;
    DATA_TYPE **data;
} matrix;

void relu(vector *vec);
void layer_pass(vector *inVec, matrix *mat, vector *outVec);
void vec_print(vector *vec);
void mat_print(matrix *mat);
vector* create_vector(int len);
matrix* create_matrix(int row, int col);
