global cropflip_asm
section .data
%define MASK_INV 00011011
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
;[rsp-4*8] = tamx
;[rsp-3*8] = tamy
;[rsp-2*8] = offsetx
;[rsp-1*8] = offsety
cropflip_asm:
    push rbp
    mov rbp, rsp
    sub rsp, 8
    push rbx
    push r12
    push r13
    push r14
    push r15
    
    pxor xmm7,xmm7
    mov r14b, [rsp - 4*8]	; mov r14b, tamx (cuantos pixeles en x me piden)
    mov cx, r14
    mov r12, cx
    mov r13b, [rsp - 3*8]	; mov r13b, tamy (cuantos pixeles en y me piden)
    mov bl, [rsp - 2*8] 	; mov rbx, offsetx
    mov rbx, [rdi + bl * 4]	; Pos de memoria de x desde donde tengo q copiar
    mov r10b, [rsp - 1*8]	; mov r10, offsety
    mov r10, [rdi + r10b * 4];Pos de memoria de y desde donde tengo q copiar 
    mov r15, rbx            ; Lo copio en r15 para no perderlo
    shr rcx, 2        		; Obtengo de a 4 pixeles
    
.ciclo:
    movdqu xmm1, [r15] ;p0|p1|p2|p3
    pshufd xmm7, xmm1,  MASK_INV ;lo doy vuelta (shuffle) ;p3|p2|p1|p0
    
    mov r12, [rsi + r12b*r13b - 16]
    
    movdqu [r12], xmm1 ;copio en la matriz en la pos r12 los pixeles de xmm1 directamente
    
    sub r12, 16 ;bajo la pos de la fila para guardar en dst
    add r15, 16 ;adelanto a los proximos 4 pixeles
    loop .ciclo
    
    
    mov r12d, r14 ;reseteo la pos de la fila
    mov cx, r14
    shr rcx, 2
    sub r13, 16	 ;descuento una fila
    cmp [rdi + r13], r10  ;
    jge .ciclo
    
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    add rsp, 8
    pop rbp
    ret
