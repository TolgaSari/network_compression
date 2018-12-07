#include <stdio.h>
#include <math.h>

#define FIXLOC          4
#define SCALER          pow(2,FIXLOC)
#define NORMALIZER      pow(SCALER,2)

float fixed_multiply(int x, int y);
// Fix point location => S 00000.00
// Multiply 3.5 with 4
// A = 0 00011.10 with B = 0 00100.00
// A x B = 4A x 4B / 16
// S = S1 XOR S2
// R = 0 01110.00
int main()
{
    int x;
    float y;
    for(x = 0; x < 128; x++)
    {
        y = fixed_multiply(x,1*SCALER);
        printf("%4d. %4f x %4f = %f\n", x,((float) x)/SCALER, 1.0, y);
    }
    
}

#define FixedMAC(acc, input, weight) acc =
float fixed_multiply(int x, int y)
{
    int input, weight;
    input = (int)(x * SCALER);
    weight = (int)(y * SCALER);
    
    float result = ((float) (x * y)) / (float)NORMALIZER;
    
    return result;
}
