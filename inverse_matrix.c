#include <stdio.h>
#define SIZE 3

void print_matrix(double matrix[3][3]) {
    for(int row = 0; row < SIZE; row++) {
        for(int col = 0; col < SIZE; col++) {
            printf("%lf ", matrix[row][col]);
        }
        printf("\n");
    }
    printf("\n");
}

int main()
{
    double matrix[3][3] = {
        {11., -11., -15.},
        {2., 3., -2.},
        {11., 13., 10.}
    };
    
    double identity[3][3] = {
        {1., 0., 0.},
        {0., 1., 0.},
        {0., 0., 1.}
    };
    
    for(int ex_row = 0 ; ex_row < SIZE; ex_row++) {
        double pivot = matrix[ex_row][ex_row];
        
        if(pivot != 0.) {
            for(int col = 0 ; col < SIZE; col++) {
                matrix[ex_row][col] /= pivot;
                identity[ex_row][col] /= pivot;
            }
        }
 
        for(int in_row = 0; in_row < SIZE; in_row++) {
            if(ex_row == in_row) continue;
            double mul = matrix[in_row][ex_row];
            for(int col = 0 ; col < SIZE; col++) {
                matrix[in_row][col] -= matrix[ex_row][col] * mul;
                identity[in_row][col] -= identity[ex_row][col] * mul;
            }
        }
    }
    
    print_matrix(matrix);
    print_matrix(identity);

    return 0;
}

