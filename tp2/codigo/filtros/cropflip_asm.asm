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
    sub rsp, 8
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
   
    mov r14d, [rsp + 4*4]	; mov r14b, tamx (cuantos pixeles en x me piden)
    mov rax, r14
    mul 4
    mov r9, eax             ; Es lo q devuelvo(ancho de fila en bytes)    
    
    mov r13d, [rsp + 3*4]	; mov r13b, tamy (cuantos pixeles en y me piden)

    mov ebx, [rsp + 2*4] 	; mov rbx, offsetx
    lea rbx, [rdi + ebx * 4]	; Pos de memoria de x desde donde tengo q copiar

    mov r10d, [rsp + 1*4]	; mov r10, offsety
    lea rbx, [rbx + r10d * r8d]	; Pos de memoria (x,y) desde donde tengo q copiar
 
    mov r15, rbx            	; Copio rbx en r15 para no perderlo

.preCiclo:
    mov rax, r14
    mul 4
    mul r13
    mov r12, rax
    lea r12, [rsi + r12]
    lea r12, [r12 - 16] 		    
	
    mov ecx, r14	    	; Guardo en ecx la cantidad de pixeles a copiar 
    shr rcx, 2        		; Obtengo de a 4 pixeles
    
.ciclo:
    movdqu xmm1, [r15] 						;p0|p1|p2|p3
    pshufd xmm7, xmm1,  MASK_INV ;lo doy vuelta (shuffle) 	;p3|p2|p1|p0
        
    movdqu [r12], xmm1 		;copio en la matriz en la pos r12 los pixeles de xmm1 directamente
    
    sub r12, 16 		    ;bajo la pos de la fila para guardar en dst
    add r15, 16 		    ;adelanto a los proximos 4 pixeles
    loop .ciclo
    
    sub r13d, 1	 		    ;descuento una fila
    cmp r13d, 0  	        ;comparo con la pos y de partida
    jge .preCiclo
    
    pop r15
    pop r14
    pop r13
    pop r12
    pop rcx
    pop rbx
    add rsp, 8
    pop rbp
    ret
