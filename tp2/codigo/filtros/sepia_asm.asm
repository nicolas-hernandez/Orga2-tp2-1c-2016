global sepia_asm

section .data
DEFAULT REL

factores: DD  0.2, 0.3, 0.5, 0.0 
alfamasc: DB  0, 0, 0, 0XFF, 0, 0, 0, 0XFF, 0, 0, 0 , 0XFF, 0, 0, 0, 0XFF
alfainv: DB 0xFF, 0xFF, 0xFF, 0, 0xFF, 0xFF, 0xFF, 0, 0xFF, 0xFF, 0xFF, 0, 0xFF, 0xFF, 0xFF, 0    
section .text

;Notacion:
;px = pixel input 
;sumax = sumatoria de las componentes de px
;px' = pixel output deseado
;El contenido de los registros XMM se muestra del 
;	bit mas significativo al menos significativo

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
	
	movdqu xmm7, [alfainv] ; XMM7 = | 00 | FF | FF | FF |...
	movdqu xmm8, [alfamasc]; XMM8 = | FF | 00 | 00 | 00 |...
	movups xmm0, [factores]
	pxor xmm6, xmm6	

	.ciclo:	
		movdqu xmm1, [rdi]; XMM1 = | p3 | p2 | p1 | p0 |
		movdqu xmm2, xmm1 ; XMM1 = XMM2
		movdqu xmm5, xmm1; respaldo XMM5 = XMM1

		;limpiar alfa
		pand xmm1, xmm7; XMM1 = | 0 | r3 | g3 | b3 |...
		pand xmm2, xmm7; idem
			
			
		punpcklbw xmm1, xmm6; XMM1 = | p1 | p0 | con alfa limpio
		punpckhbw xmm2, xmm6; XMM2 = | p3 | p2 | con alfa limpio
		
		movdqu xmm3, xmm1
		movdqu xmm4, xmm2
		punpcklbw xmm1, xmm6; XMM1 = | 0 | r0 | g0 | b0 |
		punpckhbw xmm3, xmm6; XMM3 = | 0 | r1 | g1 | b1 |
		punpcklbw xmm2, xmm6; XMM2 = | 0 | r2 | g2 | b2 |
		punpckhbw xmm4, xmm6; XMM4 = | 0 | r3 | g3 | b3 |
		
		phaddd xmm1, xmm1; XMM1 = | r0 | g0 + b0 | r0 | g0 + b0 |
		phaddd xmm1, xmm1; XMM1 = | suma0 | suma0 | suma0 | suma0 | 
		phaddd xmm2, xmm2; idem con pixeles 1, 2 y 3
		phaddd xmm2, xmm2
		phaddd xmm3, xmm3 
		phaddd xmm3, xmm3
		phaddd xmm4, xmm4
		phaddd xmm4, xmm4

		; un unpack mas, multiplico de a un pixel

		cvtdq2ps xmm1, xmm1;  suma0 asFloat
		cvtdq2ps xmm2, xmm2;  suma2 asFloat
		cvtdq2ps xmm3, xmm3;  suma1 asFloat
		cvtdq2ps xmm4, xmm4;  suma3 asFloat

		; xmmm0 tiene la mascara con los valores 0.2 0.3 0.5 0.0
		mulps xmm1, xmm0; XMM1 = |*|suma0*0.2|suma0*0.3|suma0*0.5|  
		mulps xmm2, xmm0; XMM2 = |*|suma2*0.2|suma2*0.3|suma2*0.5|  
		mulps xmm3, xmm0; XMM3 = |*|suma1*0.2|suma1*0.3|suma1*0.5|   
		mulps xmm4, xmm0; XMM4 = |*|suma3*0.2|suma3*0.3|suma3*0.5|   

		cvttps2dq xmm1, xmm1; |0|suma0*0.2 asInt|suma0*0.3 asInt|suma0*0.5 asInt|
		cvttps2dq xmm2, xmm2
		cvttps2dq xmm3, xmm3
		cvttps2dq xmm4, xmm4

		packusdw xmm1, xmm3; 
		packusdw xmm2, xmm4;
		packuswb xmm1, xmm2; XMM1 = | p3' | p2' | p1'| p0'|

		;restaurar canal alfa
		pand xmm5, xmm8
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
