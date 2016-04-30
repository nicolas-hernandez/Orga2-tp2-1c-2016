global cropflip_asm
%define MASK_INV 00011011b
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
;[rsp+ 16] = tamx
;[rsp+ 24] = tamy
;[rsp+ 32] = offsetx
;[rsp+ 40] = offsety
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

        mov r14d, [rbp + 16]    ; tamx                                  
        

        mov r13d, r14d
        shl r13, 2
        mov r9d, r13d       ; dst_row_size

        mov r13d, [rbp + 24]    ; tamy
    
        mov r12d, [rbp + 32]    ; offsetx               
    
        mov ebx, [rbp + 40] ; offsety
        mov r15d, r13d 


    
        shl r12, 2
        lea rdi, [rdi + r12]
        mov ecx, ebx

        mov eax, r8d
        mul ebx
        lea rdi, [rdi + rax]

        mov r15d, r8d
        
        mov ecx, r14d
        shl rcx, 2
        sub r15d, ecx

	xor r12, r12
        mov eax, 4  
        mul r14d
	mov r12d, eax
        mul r13d
        lea rsi, [rsi + rax]

.preCiclo:
        mov ecx, r14d          
        shr rcx, 2
	sub rsi, r12              
    
.ciclo:
        movdqu xmm1, [rdi]      ; p0|p1|p2|p3
        pshufd xmm7, xmm1,  MASK_INV    ; p3|p2|p1|p0
        
        movdqu [rsi], xmm1
    
        lea rsi, [rsi + 16]
        lea rdi, [rdi + 16]
        loop .ciclo
    
	sub rsi, r12
        lea rdi, [rdi + r15]
        sub r13d, 1  
        cmp r13d, 0        
        jne .preCiclo
    
        pop r15
        pop r14
        pop r13
        pop r12
        pop rcx
        pop rbx
        pop rbp
        ret

