section .data
DEFAULT REL

factores: DD  1.0, 0.2, 0.3, 0.5

section .text
global sepia_asm
sepia_asm:
;rdi *src
;rsi *dst
;edx int cols
;ecx int filas
;r8d int src_row_size
;r9d int dst_row_size

	push rbp
	mov rbp, rsp
	
	mov eax, edx
	mul ecx
	mov ecx, eax
	sar ecx, 2; ecx/4 me muevo cuatro pixeles por iteracion

.ciclo:	
	pxor xmm7, xmm7
	pxor xmm6, xmm6	

	movdqu xmm1, [rdi]; XMM1 = | p3 | p2 | p1 | p0 |
	movdqu xmm2, xmm1
	movdqu xmm5, xmm1; respaldo
	
	punpcklbw xmm1, xmm6; XMM1 = | p1 | p0 | 
	punpckhbw xmm2, xmm7; XMM2 = | p3 | p2 |
	
	movdqu xmm3, xmm1
	movdqu xmm4, xmm2
	
	phaddw xmm1, xmm1
	phaddw xmm1, xmm1
	phaddw xmm2, xmm2
	phaddw xmm2, xmm2;  si alfa estuviera en 0 tengo la suma en todos lados

	; un unpack mas, multiplico de a un pixel

	cvtdq2ps xmm1, xmm1
	cvtdq2ps xmm2, xmm2

	movdqu xmm0, [factores]

	mulps xmm1, xmm0 
	mulps xmm2, xmm0 

	;pack	
	
	;restaurar canal alfa

	;escribir a memoria
	movdqu [rsi], xmm1


	add rdi, 16
	loop .ciclo	
	

	pop rbp
	ret
