
#include "../tp2.h"

#define MIN(x,y) ( x < y ? x : y )
#define MAX(x,y) ( x > y ? x : y )

#define P 2

void ldr_c    (
    unsigned char *src,
    unsigned char *dst,
    int cols,
    int filas,
    int src_row_size,
    int dst_row_size,
	int alpha)
{
    unsigned char (*src_matrix)[src_row_size] = (unsigned char (*)[src_row_size]) src;
    unsigned char (*dst_matrix)[dst_row_size] = (unsigned char (*)[dst_row_size]) dst;

    for (int i = 0; i < filas; i++)
    {
        for (int j = 0; j < cols; j++)
        {
            bgra_t *p_d = (bgra_t*) &dst_matrix[i][j * 4];
            bgra_t *p_s = (bgra_t*) &src_matrix[i][j * 4];
            *p_d = *p_s;
        }
    }
}


