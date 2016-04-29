
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
    /*unsigned char (*src_matrix)[src_row_size] = (unsigned char (*)[src_row_size]) src;
    unsigned char (*dst_matrix)[dst_row_size] = (unsigned char (*)[dst_row_size]) dst;

    for (int i = 0; i < filas; i++)
    {
        for (int j = 0; j < cols; j++)
        {
            bgra_t *p_d = (bgra_t*) &dst_matrix[i][j * 4];
            bgra_t *p_s = (bgra_t*) &src_matrix[i][j * 4];
            *p_d = *p_s;
        }
    }*/

   long int c = 0;
   int colsCount = 0;
   long int total = cols*(filas-2);
   int colsToProccess = cols;
   
   if (!(cols < 5 || filas < 5)){

        colsToProccess -= 2;

        c = cols*2;
        while(c < total) {
            if(colsCount < 2) {
                //primeras dos columnas
                dst[c*4] = src[c*4];
                dst[c*4+1] = src[c*4+1];
                dst[c*4+2] = src[c*4+2];
                dst[c*4+3] = src[c*4+3];
                colsCount++;
                c++;
                dst[c*4] = src[c*4];
                dst[c*4+1] = src[c*4+1];
                dst[c*4+2] = src[c*4+2];
                dst[c*4+3] = src[c*4+3];
                colsCount++;
                c++;
            }else {
                int i = 0;
                int indexSquare = c - ((cols*2)+2);
                int sumargb = 0;
                
                while (i < 5) {
                    sumargb += src[indexSquare*4];
                    sumargb += src[indexSquare*4+1];
                    sumargb += src[indexSquare*4+2];
                    sumargb += src[indexSquare*4+4];
                    sumargb += src[indexSquare*4+5];
                    sumargb += src[indexSquare*4+6];
                    sumargb += src[indexSquare*4+8];
                    sumargb += src[indexSquare*4+9];
                    sumargb += src[indexSquare*4+10];
                    sumargb += src[indexSquare*4+12];
                    sumargb += src[indexSquare*4+13];
                    sumargb += src[indexSquare*4+14];
                    sumargb += src[indexSquare*4+16];
                    sumargb += src[indexSquare*4+17];
                    sumargb += src[indexSquare*4+18];
                    indexSquare += cols; //siguiente fila.
                    i++;
                }

                float sumargbf = sumargb;
                float alphaf = alpha;
                float maxf = 4876875;
                float b = (float)src[c*4];
                float g = (float)src[c*4+1];
                float r = (float)src[c*4+2];
                unsigned char a = src[c*4+3];

                b = b + (alphaf*sumargbf*b)/maxf;

                b = MIN(MAX(b,0), 255);

                g = g + (alphaf*sumargbf*g)/maxf;

                g = MIN(MAX(g,0), 255);

                r = r + (alphaf*sumargbf*r)/maxf;

                r = MIN(MAX(r,0), 255);

                dst[c*4] = (unsigned char)b;
                dst[c*4+1] = (unsigned char)g;
                dst[c*4+2] = (unsigned char)r;
                dst[c*4+3] = a;

                colsCount++;
                c++;

                if (colsCount == colsToProccess) {
                    //ultimas dos
                    dst[c*4] = src[c*4];
                    dst[c*4+1] = src[c*4+1];
                    dst[c*4+2] = src[c*4+2];
                    dst[c*4+3] = src[c*4+3];
                    c++;
                    dst[c*4] = src[c*4];
                    dst[c*4+1] = src[c*4+1];
                    dst[c*4+2] = src[c*4+2];
                    dst[c*4+3] = src[c*4+3];
                    c++;

                    colsCount = 0;
                }
            }
        }
   }

   c = 0;
   long int lastC = total; //cols*filas - cols*2
   total = cols*2;
   while (c < total) {
        dst[c*4] = src[c*4];
        dst[c*4+1] = src[c*4+1];
        dst[c*4+2] = src[c*4+2];
        dst[c*4+3] = src[c*4+3];
        //cuando complete las dos primeras, completo las dos ultimas.
        dst[lastC*4] = src[lastC*4];
        dst[lastC*4+1] = src[lastC*4+1];
        dst[lastC*4+2] = src[lastC*4+2];
        dst[lastC*4+3] = src[lastC*4+3];
        
        lastC++;
        c++;
   }
}


