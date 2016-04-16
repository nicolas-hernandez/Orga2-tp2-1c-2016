
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "../tp2.h"
void ldr_asm    (unsigned char *src, unsigned char *dst, int cols, int filas,
                      int src_row_size, int dst_row_size, int alpha);

void ldr_c    (unsigned char *src, unsigned char *dst, int cols, int filas,
                      int src_row_size, int dst_row_size, int alpha);

typedef void (ldr_fn_t) (unsigned char*, unsigned char*, int, int, int, int, int);


int alpha;

void leer_params_ldr(configuracion_t *config, int argc, char *argv[]) {
	config->extra_config = &alpha;
    alpha = atoi(argv[argc - 1]);
}

void aplicar_ldr(configuracion_t *config)
{
	ldr_fn_t *ldr = SWITCH_C_ASM ( config, ldr_c, ldr_asm ) ;
	buffer_info_t info = config->src;
	ldr(info.bytes, config->dst.bytes, info.width, info.height, info.width_with_padding,
	         config->dst.width_with_padding, alpha);

}

void ayuda_ldr()
{
	printf ( "       * ldr\n" );
	printf ( "           Parámetros     : \n"
	         "                         alpha - valor entre -255 y 255. En caso"
             "                         de querer pasar un valor negativo anteponer --\n");
	printf ( "           Ejemplo de uso : \n"
	         "                         ldr -i c facil.bmp 120\n"
             "                         ldr -i c facil.bmp -- -200\n");
}


