// Macros for the sake of more data intependent code.
#define DATA_TYPE float
#define PRINT_TYPE 0 // 0 for DATA_TYPE = 1
#define PRINT_STR "%f "//"%d "
#define READ_STR "%f"

#define RELU(x) x = x > 0 ? x : 0

typedef struct
{
    DATA_TYPE *data;
    int len;
} vector;

typedef struct
{
    int shape[2];
    DATA_TYPE **data;
} matrix;

typedef struct
{
    int layer_count;
    vector *biases;
    matrix *layers;
} network;

void relu(vector *vec);
void vector_print(vector *vec);
void matrix_print(matrix *mat);
void read_image(char* file_name, int sample_size, int image_size, vector* image);
void create_network(char* file_name, network* nn);
void layer_pass(matrix* layer, vector* bias, vector* input, vector* output);

vector* create_vector_list(int count, int len);
vector* create_vector(int len);

matrix* create_matrix(int row, int col);
