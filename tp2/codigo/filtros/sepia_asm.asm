section .data
DEFAULT REL

factores: DD 0.0, 0.2, 0.3, 0.5
alfamasc: DB 0XFF, 0, 0, 0, 0XFF, 0, 0, 0, 0XFF, 0, 0, 0 , 0XFF, 0, 0, 0
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
	
	movdqu xmm7, [alfamasc]

.ciclo:	
	pxor xmm6, xmm6	

	movdqu xmm1, [rdi]; XMM1 = | p3 | p2 | p1 | p0 |
	movdqu xmm2, xmm1
	movdqu xmm5, xmm1; respaldo

	;limpiar alfa?
	
	punpcklbw xmm1, xmm6; XMM1 = | p1 | p0 | 
	punpckhbw xmm2, xmm7; XMM2 = | p3 | p2 |
	
	phaddw xmm1, xmm1
	phaddw xmm1, xmm1
	phaddw xmm2, xmm2
	phaddw xmm2, xmm2

	; un unpack mas, multiplico de a un pixel
	movdqu xmm3, xmm1
	movdqu xmm4, xmm2

	punpcklbw xmm1, xmm6
	punpckhbw xmm3, xmm6
	punpcklbw xmm2, xmm6
	punpckhbw xmm4, xmm6
	cvtdq2ps xmm1, xmm1
	cvtdq2ps xmm2, xmm2
	cvtdq2ps xmm3, xmm3
	cvtdq2ps xmm4, xmm4

	movdqu xmm0, [factores]

	mulps xmm1, xmm0 
	mulps xmm2, xmm0 
	mulps xmm3, xmm0 
	mulps xmm4, xmm0 

	cvttps2dq xmm1, xmm1
	cvttps2dq xmm2, xmm2
	cvttps2dq xmm3, xmm3
	cvttps2dq xmm4, xmm4

	;pack	
	packusdw xmm1, xmm3
	packusdw xmm2, xmm4
	packuswb xmm1, xmm2
	
	;restaurar canal alfa
	pand xmm5, xmm7
	paddb xmm1, xmm5
	;escribir a memoria
	movdqu [rsi], xmm1


	add rdi, 16	
	add rsi, 16

	dec ecx
	cmp ecx, 0
	jg .ciclo	
	
	pop rbp
	ret
