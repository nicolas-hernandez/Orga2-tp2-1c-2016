global ldr_asm

section .data
DEFAULT REL

;%define WHITE 255
;%define BLACK 0

; En memoria: BGRA
; En registros: ARGB
; a3|r3|g3|b3|a2|r2|g2|b2|a1|r1|g1|b1|a0|r0|g0|b0 -> a3|a2|a1|a0|r3|g3|b3|r2|g2|b2|r1|g1|b1|r0|g0|b0
ordenarCanalesPixelesImparesAWord: DB 0x00, 0x83, 0x01, 0x84, 0x02, 0x85, 0x86, 0x87, 0x08, 0x8B, 0x09, 0x8C, 0x0A, 0x8D, 0x8E, 0x8F 
ordenarCanalesPixelesParesAWord: DB 0x04, 0x80, 0x05, 0x81, 0x06, 0x82, 0x83, 0x87, 0x0C, 0x88, 0x0D, 0x89, 0x0E, 0x8A, 0x8B, 0x8F 
ordenarADoubleWord: DB 0x00, 0x01, 0x88, 0x89, 0x2, 0x03, 0x8A, 0x8B, 0x04, 0x05, 0x8C, 0x8D, 0x06, 0x07, 0x8E, 0x8F
salvarUnPixelShifteable: DB 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0x00
maxValue: DD 0x004A6A4B ; check this 4876875

section .text
;void ldr_asm    (
	;unsigned char *src, rdi
	;unsigned char *dst, rsi
	;int filas, edx
	;int cols, ecx
	;int src_row_size, r8d -> no se usa
	;int dst_row_size, r9d -> no se usa
	;int alpha) rsp-8

	; r8 posicion actual
	; r9 contador columnas

ldr_asm:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14
	push r15

	xor rbx, rbx
	xor r12, r12
	xor r13, r13
	xor r14, r14
	xor r15, r15
	
	mov ebx, [rbp+16] ; alpha
	mov r13d, [maxValue] ; MAX

	cmp ebx, -255
	jl .sinCambios
	cmp ebx, 255
	jg .sinCambios
	cmp edx, 4
	jle .sinCambios ; si tengo menos de cuatro filas terminar.
	cmp ecx, 4
	jle .sinCambios ; si tengo menos que cuatro columnas terminar.

	xor r8, r8 ; posicion actual
	xor r9, r9 ; j = 0
	mov r8d, ecx ; r8 = columnas

	mov r15d, ecx ; r15d = columnas 
	xor rcx, rcx
	mov r14d, edx ; r14d = filas 
	xor rax, rax ; limpio para usar en multiplicacion.
	mov eax, r15d
	mul r14d ; edx:eax = r15d*r14d = columnas*filas.
	mov ecx, edx
	shl rdx, 32
	mov ecx, eax ; ecx = r15d*r14d = columnas*filas. contador loop.

	xor rdx, rdx ; parte alta - resto 
	xor rax, rax ; parte baja - cociente.
	xor r11, r11
	mov eax, r15d
	mov r11, 2
	div r11d ; divido columnas por dos - resto en edx (from 0 to 1) 
	xor r11, r11
	mov r11d, r15d
	sub r11d, edx ; edx: 0 or 1
	sub r11d, 2 ; (columnas-resto)-2 = colsToProccess

	shl r8, 1 ; r8*2 = i = 2 - j = 0

	movdqu xmm6, [ordenarCanalesPixelesImparesAWord]
	movdqu xmm7, [ordenarCanalesPixelesParesAWord]
	movdqu xmm8, [salvarUnPixelShifteable]
	movdqu xmm11, [ordenarADoubleWord]
	movdqu xmm15, xmm8 ; 0|FF|FF|FF|0|0|0|0|0|0|0|0|0|0|0|0
    psrldq xmm15, 12 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|FF|FF|FF

.ciclo: ; while(r8 < rcx) == (actual < total) 
; if(j > 1)
	cmp r9, 2
	jl .menorAColDos
	; estoy en rango.
	mov r12, r8 ; posicion actual
	sub r12, r15
	sub r12, r15 ; posicion actual - dos filas
	sub r12, 2 ; me corro -2 posiciones
	xor r10, r10 ; cuento hasta 5

	pxor xmm0, xmm0

.cincoHorizontal: ; Puedo procesar 5 pixeles en paralelo - los pixeles que estan en columnas mayores a colsToProccess no se tendran en cuenta.

	;          20  16  12   8   4   0
	; Li7|Li6|Li5|Li4|Li3|Li2|Li1|Li0
	pxor xmm10, xmm10

	movdqu xmm13, [rdi + r12*4] ; Li3|Li2|Li1|Li0
	movdqu xmm9, xmm13
	pshufb xmm9, xmm6 ; ordenarCanalesPixelesImparesAWord
	phaddw xmm9, xmm10 ; maximo por dw = 510 = 0x01FE
	pshufb xmm13, xmm7 ; ordenarCanalesPixelesParesAWord
    phaddw xmm13, xmm10 ; maximo por dw = 510 = 0x01FE
    pshufb xmm9, xmm11 ; ordenarADoubleWord
    pshufb xmm13, xmm11 ; ordenarADoubleWord
    cvtdq2ps xmm9, xmm9
    cvtdq2ps xmm13, xmm13
    addps xmm13, xmm9 ; cuatro fp sumados
    movdqu xmm9, xmm13 ; shifteo dos fp de la parte alta a la parte baja
    psrldq xmm9, 8
    addps xmm13, xmm9 ; dos fp en la parte baja 
    pslldq xmm13, 8
    psrldq xmm13, 8 ; limpio parte alta
    
	movd xmm9, [rdi + r12*4 + 16] ; 0|0|0|0|0|0|0|0|0|0|0|0|a4|r4|g4|b4

	pslldq xmm9, 12 ; a4|r4|g4|b4|0|0|0|0|0|0|0|0|0|0|0|0
	pand xmm9, xmm8 ; 0|r4|g4|b4|0|0|0|0|0|0|0|0|0|0|0|0
	pshufb xmm9, xmm7 ; ordenarCanalesPixelesParesAWord
	phaddw xmm9, xmm10
	pshufb xmm9, xmm11 ; ordenarADoubleWord
	cvtdq2ps xmm9, xmm9 ; dos fp en la parte alta
	psrldq xmm9, 8
	addps xmm13, xmm9 ; dos fp en la parte baja 
	movdqu xmm9, xmm13
	psrldq xmm9, 4
	addps xmm13, xmm9 ; un fp en la parte baja
	pslldq xmm13, 12
	psrldq xmm13, 12
	addps xmm0, xmm13 ; suma de la i fila para el pixel index 4.

	add r12, r15
	inc r10
	cmp r10, 5
	jl .cincoHorizontal

	pxor xmm13, xmm13
	cvtsi2ss xmm13, ebx ; cast to float!
	movdqu xmm12, xmm13 ; 0|0|0|alpha
	pslldq xmm12, 4 ; 0|0|alpha|0
	por xmm12, xmm13 ; 0|0|alpha|alpha
	pslldq xmm12, 4 ; 0|alpha|alpha|0
	por xmm12, xmm13 ; 0|alpha|alpha|alpha

	pxor xmm14, xmm14
	cvtsi2ss xmm14, r13d ; cast to float! 
	movdqu xmm13, xmm14 ; 0|0|0|max
	pslldq xmm13, 4 ; 0|0|max|0
	por xmm13, xmm14 ; 0|0|max|max
	pslldq xmm13, 4 ; 0|max|max|0
	por xmm13, xmm14 ; 0|max|max|max
	pslldq xmm13, 4 ; max|max|max|0
	por xmm13, xmm14 ; max|max|max|max

	cmp r9, r11
	jge .mayorIgAColsToProccess ; mayor igual a colsToProccess

    psrldq xmm8, 14
    pslldq xmm8, 3 ; 0|0|0|0|0|0|0|0|0|0|0|0|F|0|0|0

	movdqu xmm5, xmm0
	pslldq xmm5, 4
	por xmm5, xmm0
	pslldq xmm5, 4
	por xmm5, xmm0
	pxor xmm14, xmm14
	movd xmm14, [rdi + r8*4] ; 0|0|0|0|0|0|0|0|0|0|0|0|aj|rj|gj|bj <- get pixel ij
	movdqu xmm0, xmm14 ; 0|0|0|0|0|0|0|0|0|0|0|0|aj|rj|gj|bj
	pand xmm0, xmm15 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|rj|gj|bj
	pxor xmm10, xmm10
	punpcklbw xmm0, xmm10 ; 0|0|0|0|0|rj|gj|bj
	punpcklwd xmm0, xmm10 ; 0|rj|gj|bj
	cvtdq2ps xmm0, xmm0 ; cast to float!
	mulps xmm5, xmm0 ; 0|sumargb_i,j*rj|sumargb_i,j*gj|sumargb_i,j*bj
	mulps xmm5, xmm12 ; 0|alpha*sumargb_i,j*rj|alpha*sumargb_i,j*gj|alpha*sumargb_i,j*bj <- puede cambiar el signo segun alpha.
	divps xmm5, xmm13 ; 0|(alpha*sumargb_i,j*rj)/max|(alpha*sumargb_i,j*gj)/max|(alpha*sumargb_i,j*bj)/max
	addps xmm5, xmm0 ; 0|rj+(alpha*sumargb_i,j*rj)/max|gj+(alpha*sumargb_i,j*gj)/max|bj+(alpha*sumargb_i,j*bj)/max
	
	cvttps2dq xmm5, xmm5 ; cast to dw signed 
	pxor xmm10, xmm10
	packusdw xmm5, xmm10 ; 0|0|0|0|0|rj+(alpha*sumargb_i,j*rj)/gj+max|(alpha*sumargb_i,j*gj)/bj+max|(alpha*sumargb_i,j*bj)/max
	packuswb xmm5, xmm10 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|rj+(alpha*sumargb_i,j*rj)/gj+max|(alpha*sumargb_i,j*gj)/bj+max|(alpha*sumargb_i,j*bj)/max <- tengo los canales calculados saturados a byte.
	pand xmm14, xmm8 ; 0|0|0|0|0|0|0|0|0|0|0|0|aj|0|0|0
	por xmm14, xmm5 ; 0|0|0|0|0|0|0|0|0|0|0|0|aj|rj+(alpha*sumargb_i,j*rj)/max|gj+(alpha*sumargb_i,j*gj)/max|bj+(alpha*sumargb_i,j*bj)/max

    movd [rsi + r8*4], xmm14

	inc r9
	inc r8
	cmp r9, r11
	jge .mayorIgAColsToProccess ; mayor igual a colsToProccess
	jmp .seguir

.menorAColDos:
; Tengo que devolver r9
	pxor xmm10, xmm10
	movd xmm10, [rdi + r8*4]
	movd [rsi + r8*4], xmm10
	inc r8
	inc r9
	jmp .seguir

.mayorIgAColsToProccess:
; Tengo que devolver las columnas:
; r8, r8+1 && edx==1?r8+2 
	pxor xmm10, xmm10
	movd xmm10, [rdi + r8*4]
	movd [rsi + r8*4], xmm10
	inc r8
	movd xmm10, [rdi + r8*4]
	movd [rsi + r8*4], xmm10
	cmp edx, 1
	jne .continuar
	inc r8 ; columna impar final
	movd xmm10, [rdi + r8*4]
	movd [rsi + r8*4], xmm10

.continuar:
	xor r9, r9 ; reinicio contador columna actual.
    inc r8

.seguir:
	movdqu xmm8, xmm15 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|FF|FF|FF
	pslldq xmm8, 12 ; 0|FF|FF|FF|0|0|0|0|0|0|0|0|0|0|0|0
	cmp r8, rcx
	jl .ciclo

.sinCambios:
	xor r8, r8
	xor r9, r9
	mov r9, rcx ; columnas*filas
	shl r15, 1 ; r15*2
	sub r9, r15 ; ante-ultima fila, posicion 0
.devolver:
	movdqu xmm10, [rdi + r8*4]
	movdqu xmm11, [rdi + r9*4]
	movdqu [rsi + r8*4], xmm10
	movdqu [rsi + r9*4], xmm11
	add r8, 4
	add r9, 4
	cmp r8, r15 ; cuando complete las dos primeras, tambien completo las dos ultimas.
	jl .devolver

; DONE!!.

.salir:
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret
