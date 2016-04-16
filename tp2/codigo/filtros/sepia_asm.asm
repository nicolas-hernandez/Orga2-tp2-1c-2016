section .data
DEFAULT REL

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
	movdqu xmm1, [rdi]; XMM1 = | p3 | p2 | p1 | p0 |

		
		
	add rdi, 16
	loop .ciclo	
	

	pop rbp
	ret
