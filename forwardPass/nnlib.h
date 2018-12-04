#define DATA_TYPE float

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
void read_image(char* file_name, int sample_size, int image_size, DATA_TYPE** image);
