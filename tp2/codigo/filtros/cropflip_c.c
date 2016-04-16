
#include "../tp2.h"

void cropflip_c    (
	unsigned char *src,
	unsigned char *dst,
	int cols,
	int filas,
	int src_row_size,
	int dst_row_size,
	int tamx,
	int tamy,
	int offsetx,
	int offsety)
{
	unsigned char (*src_matrix)[src_row_size] = (unsigned char (*)[src_row_size]) src;
	unsigned char (*dst_matrix)[dst_row_size] = (unsigned char (*)[dst_row_size]) dst;

	// ejemplo de uso de src_matrix y dst_matrix (copia una parte de la imagen)

	for (int i = 0; i < tamy; i++) {
		for (int j = 0; j < tamx; j++) {
			bgra_t *p_d = (bgra_t*) &dst_matrix[i][j * 4];
            bgra_t *p_s = (bgra_t*) &src_matrix[i][j * 4];

			p_d->b = p_s->b;
			p_d->g = p_s->g;
			p_d->r = p_s->r;
			p_d->a = p_s->a;

		}
	}


}
