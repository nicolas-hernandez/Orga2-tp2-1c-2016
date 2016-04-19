global cropflip_asm

section .text
;void cropflip_asm(unsigned char *src,
;                  unsigned char *dst,
;		           int cols, int filas,
;                  int src_row_size,
;                  int dst_row_size,
;                  int tamx, int tamy,
;                  int offsetx, int offsety);
;rdi = *src
;rsi = *dst
;rdx = cols
;rcx = filas
;r8 = src_row_size
;r9 = dst_row_size
cropflip_asm:
    push rbp
	mov rbp, rsp
	
	;mov rbx, offsetx  <--lo obtengo de la pila
	;mov eax, tamx     <--lo obtengo de la pila
	;shr rcx, 2
	;mov r10, *vector <--- libero memoria y eso/esto es un bardo despues veo una mejor forma(tal vez copiando en dst directamente)
	;mov r11, r10
.ciclo:
    movups xmm1, [rdi + rbx]
    movups [r11],xmm1
	add rbx, 16    
	loop .ciclo
	
	mov rbx, rsi; + offsetx*offsety
.ciclo2:
    mov r11,
    mov rbx,
	
	pop rbp
    ret
