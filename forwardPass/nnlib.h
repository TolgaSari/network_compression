// Macros for the sake of more data intependent code.
#define QUANTIZED

#ifdef QUANTIZED
    #define DATA_TYPE int
    #define PRINT_STR "%2d "//"%d "
    #define READ_STR "%d"
#else
    #define DATA_TYPE float
    #define PRINT_STR "%0.2f "//"%d "
    #define READ_STR "%f"
#endif

#define RELU(x) x = x > 0 ? x : 0
#define NEWLINE printf("\n");


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
    float *qtable;
} network;

void relu(vector *vec);
void vector_print(vector *vec);
void matrix_print(matrix *mat);
void read_image(char* file_name, int sample_size, int image_size, vector* image);
void layer_pass(matrix* layer, vector* bias, vector* input, vector* output, float *qtable);
void network_print(network* nn);
void compress_zeros(char *filename);
int forward_pass(network* nn, vector* input);
int get_max(vector *vec);

float evaluate(network *nn, vector* images, vector* labels);

vector* create_vector_list(int count, int len);
vector* create_vector(int len);

matrix* create_matrix(int row, int col);

network* create_network(char* file_name);
