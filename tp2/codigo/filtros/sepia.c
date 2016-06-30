
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "../tp2.h"

void sepia_asm    (unsigned char *src, unsigned char *dst, int cols, int filas,
                      int src_row_size, int dst_row_size, int alfa);

void sepia_c    (unsigned char *src, unsigned char *dst, int cols, int filas,
                      int src_row_size, int dst_row_size, int alfa);

typedef void (sepia_fn_t) (unsigned char*, unsigned char*, int, int, int, int, int);


int alfa;

void leer_params_sepia(configuracion_t *config, int argc, char *argv[]) {
	config->extra_config = &alfa;
    alfa = atoi(argv[argc - 1]);
}

void aplicar_sepia(configuracion_t *config)
{
	sepia_fn_t *sepia = SWITCH_C_ASM ( config, sepia_c, sepia_asm ) ;
	buffer_info_t info = config->src;
	sepia(info.bytes, config->dst.bytes, info.width, info.height, info.width_with_padding,
	         config->dst.width_with_padding, alfa);

}

void ayuda_sepia()
{
	printf ( "       * sepia\n" );
	printf ( "           Parámetros     : \n"
	         "                         ninguno\n");
	printf ( "           Ejemplo de uso : \n"
             "                         sepia -i c bgr.bmp\n");
}

