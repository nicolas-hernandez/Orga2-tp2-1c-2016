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
    sub rsp, 8
    push rbx
    push r12
    push r13
    push r14
    push r15
	
	;mov r14d, tamx     <--lo obtengo de la pila
	;mov eax, r14d
	;mov r12d, eax
	;mov r13d, tamy    <--lo obtengo de la pila
	;mov r10, [rdi + offsety * 4]  <--lo obtengo de la pila
	;mov rbx, [rdi + offsetx * 4]  <--lo obtengo de la pila
	;mov r15, rbx
	;shr rcx, 2        <--obtengo de a 4 pixeles
.ciclo:
    movdqu xmm1, [rdi + r15] ;p0|p1|p2|p3
    ;*******
    ;lo doy vuelta (shuffle) ;p3|p2|p1|p0
    ;*******
    
    mov r12, [rsi + r12d*r13d - 16]  ;<-- pushea r12
    ;*******
    movdqu [r12], xmm1;copio en la matriz en la pos r12 los pixeles de xmm1 directamente
    ;*******
    sub r12, 16 ;bajo la pos de la fila para guardar en dst
    add r15, 16 ;adelanto a los proximos 4 pixeles
    loop .ciclo
    
    
    mov r12d, r14 ;reseteo la pos de la fila
    mov eax, r14
    sub r13, 16	 ;descuento una fila
    jge [rdi + r13], r10  ;
    
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    add rsp, 8
    pop rbp
    ret
