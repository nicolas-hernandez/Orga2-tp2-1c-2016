global cropflip_asm
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
;edx = cols
;ecx = filas
;r8d = src_row_size
;r9d = dst_row_size
;[rsp+4*4] = tamx
;[rsp+3*4] = tamy
;[rsp+2*4] = offsetx
;[rsp+1*4] = offsety
cropflip_asm:
    push rbp
    mov rbp, rsp
    push rbx
    push rcx
    push r12
    push r13
    push r14
    push r15

    xor r12, r12
    xor r13, r13
    xor r14, r14
    xor r10, r10
    xor rcx, rcx
    xor r15, r15
    xor rbx, rbx

	mov r14d, [rbp + 16]	 			;(cuantos pixeles en x me piden)                     			
    
    mov r13d, r14d
    shl r13, 2
    mov r9d, r13d						; Es lo q devuelvo(ancho de fila en bytes)

    mov r13d, [rbp + 24]	; mov r13b, tamy (cuantos pixeles en y me piden)
    
    mov r12d, [rbp + 32] 	; mov r12, offsetx			    
							    
	mov ebx, [rbp + 40]
							 
	mov r15d, r13d 

.preC:
	mov ecx, r14d
	shr rcx, 2
.c:
	lea rsi, [rsi + 16]
	loop .c
	sub r15d, 1	 		    
    cmp r15d, 0  	        
    jne .preC


    shl r12, 2
    lea rdi, [rdi + r12]
    shl ebx, 2
    mov ecx, ebx

    mov r15d, r8d
    shr r15, 2

    .sumarDir:				;usaria "mul r8d" pero por alguna razon no anda
    lea rdi, [rdi + r15]
    loop .sumarDir

    shl r15, 2
    mov ecx, r14d
    shl rcx, 2
    sub r15d, ecx

.preCiclo:
					    
    mov ecx, r14d			; Guardo en ecx la cantidad de pixeles a copiar 
    shr rcx, 2        		; Obtengo de a 4 pixeles
    
.ciclo:
    movdqu xmm1, [rdi] 										;p0|p1|p2|p3
    pshufd xmm7, xmm1,  MASK_INV ;lo doy vuelta (shuffle) 	 p3|p2|p1|p0
        
    movdqu [rsi], xmm7 		;copio en la matriz en la pos r12 los pixeles de xmm1 directamente
    
    lea rsi, [rsi - 16] 		    ;bajo la pos de la fila para guardar en dst
    lea rdi, [rdi + 16] 		    ;adelanto a los proximos 4 pixeles
    loop .ciclo
    

    lea rdi, [rdi + r15]
    sub r13d, 1	 		    ;descuento una fila
    cmp r13d, 0 	        ;comparo con la pos y de partida
    jne .preCiclo
    
    pop r15
    pop r14
    pop r13
    pop r12
    pop rcx
    pop rbx
    pop rbp
    ret
