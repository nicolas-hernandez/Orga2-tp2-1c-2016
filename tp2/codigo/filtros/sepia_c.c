
#include "../tp2.h"


void sepia_c    (
    unsigned char *src,
    unsigned char *dst,
    int cols,
    int filas,
    int src_row_size,
    int dst_row_size)
{
    unsigned char (*src_matrix)[src_row_size] = (unsigned char (*)[src_row_size]) src;
    unsigned char (*dst_matrix)[dst_row_size] = (unsigned char (*)[dst_row_size]) dst;
	
	int aux;

    for (int i = 0; i < filas; i++)
    {
        for (int j = 0; j < cols; j++)
        {
            bgra_t *p_d = (bgra_t*) &dst_matrix[i][j * 4];
            bgra_t *p_s = (bgra_t*) &src_matrix[i][j * 4];
            aux = (int) p_s->r + (int) p_s->g + (int) p_s->b;
			p_d->r = (aux * 0.5 > 255)? 255 : aux * 0.5;
			p_d->g = (aux * 0.3 > 255)? 255 : aux * 0.3;
			p_d->b = (aux * 0.2 > 255)? 255 : aux * 0.2;
			p_d->a = p_s->a;
        }		
    }	
}



