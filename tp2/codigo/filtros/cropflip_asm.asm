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
	
	;mov r14d, tamx     <--lo obtengo de la pila
	;mov eax, r14d
	;mov r12d, eax
	;mov r13d, tamy    <--lo obtengo de la pila
	;mov r10, offsety  <--lo obtengo de la pila
	;mov rbx, offsetx  <--lo obtengo de la pila
	;mov r15, rbx
	;shr rcx, 2        <--obtengo de a 4 pixeles
.ciclo:
    movups xmm1, [rdi + r15] ;p0|p1|p2|p3
    ;*******
    ;lo doy vuelta (shuffle) ;p3|p2|p1|p0
    ;*******
    
    mov r12, [rsi + r12d*r13d - 16]  ;<-- pushea r12
    ;*******
    ;copio en la matriz en la pos r12 los pixeles de xmm1 directamente
    ;*******
    sub r12, 16 ;bajo la pos de la fila para guardar en dst
    add r15, 16 ;adelanto a los proximos 4 pixeles
    loop .ciclo
    
    
    mov r12, r14 ;reseteo la pos de la fila
    sub r13, 16	 ;descuento una fila
    jge [rdi + r13], r10  ;
    

    pop rbp
    ret
