global ldr_asm

section .data
DEFAULT REL

%define WHITE 255
%define BLACK 0

; En memoria: BGRA
; En registros: ARGB

; a3|r3|g3|b3|a2|r2|g2|b2|a1|r1|g1|b1|a0|r0|g0|b0 -> a3|a2|a1|a0|r3|g3|b3|r2|g2|b2|r1|g1|b1|r0|g0|b0
juntarCanalesAlpha: db 0x00, 0x01, 0x02, 0x8C, 0x03, 0x04, 0x05, 0x8D, 0x06, 0x07, 0x08, 0x8E, 0x09, 0x0A, 0x0B, 0x8F 
;limpiarCanalesAlpha: db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00
salvarUnPixelShifteable: db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0x00
maxValue: dd 0x004A6A4B ; check this 4876875

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

	movdqu xmm6, [juntarCanalesAlpha]
	;movdqu xmm7, [limpiarCanalesAlpha]
	movdqu xmm8, [salvarUnPixelShifteable]
	movdqu xmm15, xmm8 ; 0|0|0|0|0|0|0|0|0|0|0|0|FF|FF|FF|0
    psrldq xmm15, 1 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|FF|FF|FF

.ciclo: ; while(r8 < rcx) == (actual < total) 
; if(j > 1)
	cmp r9, 2
	jl .menorAColDos
	; estoy en rango.
	xor r12, r12
	mov r12, r8 ; posicion actual
	sub r12, r15
	sub r12, r15 ; posicion actual - dos filas
	sub r12, 2 ; me corro -2 posiciones
	xor r10, r10 ; cuento hasta 5

	pxor xmm13, xmm13 ; acumulo la suma de los cuadrados de 5 pixeles.
.cincoEnParalelo: ; Puedo procesar 5 pixeles en paralelo - los pixeles que estan en columnas mayores a colsToProccess no se tendran en cuenta.

	;          20  16  12   8   4   0
	; Li7|Li6|Li5|Li4|Li3|Li2|Li1|Li0

	movdqu xmm0, [rdi + r12*4] ; Li3|Li2|Li1|Li0
	pshufb xmm0, xmm6 ; 0|0|0|0|r3|g3|b3|r2|g2|b2|r1|g1|b1|r0|g0|b0
	
	movdqu xmm1, [rdi + r12*4 + 4] ; Li4|Li3|Li2|Li1
	pshufb xmm1, xmm6 ; 0|0|0|0|r4|g4|b4|r3|g3|b3|r2|g2|b2|r1|g1|b1
	
	pxor xmm9, xmm9
	movdqu xmm9, xmm1
	pslldq xmm9, 3 ; 0|r4|g4|b4|r3|g3|b3|r2|g2|b2|r1|g1|b1|0|0|0
	pand xmm9, xmm8 ; 0|r4|g4|b4|0|0|0|0|0|0|0|0|0|0|0|0
	por xmm0, xmm9 ; 0|r4|g4|b4|r3|g3|b3|r2|g2|b2|r1|g1|b1|r0|g0|b0

	movdqu xmm2, [rdi + r12*4 + 8] ; Li5|Li4|Li3|Li2
	pshufb xmm2, xmm6 ; 0|0|0|0|r5|g5|b5|r4|g4|b4|r3|g3|b3|r2|g2|b2
	
	pxor xmm9, xmm9
	movdqu xmm9, xmm2
	pslldq xmm9, 3 ; 0|r5|g5|b5|r4|g4|b4|r3|g3|b3|r2|g2|b2|0|0|0
	pand xmm9, xmm8 ; 0|r5|g5|b5|0|0|0|0|0|0|0|0|0|0|0|0
	por xmm1, xmm9 ; 0|r5|g5|b5|r4|g4|b4|r3|g3|b3|r2|g2|b2|r1|g1|b1

	movdqu xmm3, [rdi + r12*4 + 12] ; Li6|Li5|Li4|Li3
	pshufb xmm3, xmm6 ; 0|0|0|0|r6|g6|b6|r5|g5|b5|r4|g4|b4|r3|g3|b3
	
	pxor xmm9, xmm9
	movdqu xmm9, xmm3
	pslldq xmm9, 3 ; 0|r6|g6|b6|r5|g5|b5|r4|g4|b4|r3|g3|b3|0|0|0
	pand xmm9, xmm8 ; 0|r6|g6|b6|0|0|0|0|0|0|0|0|0|0|0|0
	por xmm2, xmm9 ; 0|r6|g6|b6|r5|g5|b5|r4|g4|b4|r3|g3|b3|r2|g2|b2

	movdqu xmm4, [rdi + r12*4 + 16] ; Li7|Li6|Li5|Li4
	pshufb xmm4, xmm6 ; 0|0|0|0|r7|g7|b7|r6|g6|b6|r5|g5|b5|r4|g4|b4
	
	pxor xmm9, xmm9
	movdqu xmm9, xmm4
	pslldq xmm9, 3 ; 0|r7|g7|b7|r6|g6|b6|r5|g5|b5|r4|g4|b4|0|0|0
	pand xmm9, xmm8 ; 0|r7|g7|b7|0|0|0|0|0|0|0|0|0|0|0|0
	por xmm3, xmm9 ; 0|r7|g7|b7|r6|g6|b6|r5|g5|b5|r4|g4|b4|r3|g3|b3

	pxor xmm9, xmm9
	movd xmm9, [rdi + r12*4 + 28] ; 0|0|0|0|0|0|0|0|0|0|0|0|a8|r8|g8|b8
	pslldq xmm9, 12 ; a8|r8|g8|b8|0|0|0|0|0|0|0|0|0|0|0|0
	pand xmm9, xmm8 ; 0|r8|g8|b8|0|0|0|0|0|0|0|0|0|0|0|0
	por xmm4, xmm9 ; 0|r8|g8|b8|r7|g7|b7|r6|g6|b6|r5|g5|b5|r4|g4|b4

	; realizar suma vertical de bytes saturada y acumular en xmm9, 
	pxor xmm9, xmm9
	paddusb xmm9, xmm0
	paddusb xmm9, xmm1
	paddusb xmm9, xmm2
	paddusb xmm9, xmm3
	paddusb xmm9, xmm4 ; 0|sum(r4)|sum(g4)|sum(b4)|sum(r3)|sum(g3)|sum(b3)|sum(r2)|sum(g2)|sum(b2)|sum(r1)|sum(g1)|sum(b1)|sum(r0)|sum(g0)|sum(b0)

	; pixel suma 4
	; mascara: xmm8
	pxor xmm10, xmm10
	movdqu xmm10, xmm9 ; 0|sum(r4)|sum(g4)|sum(b4)|sum(r3)|sum(g3)|sum(b3)|sum(r2)|sum(g2)|sum(b2)|sum(r1)|sum(g1)|sum(b1)|sum(r0)|sum(g0)|sum(b0)
	pand xmm10, xmm8 ; 0|sum(r)|sum(g)|sum(b)|0|0|0|0|0|0|0|0|0|0|0|0
	pxor xmm11, xmm11
	; unpack a word 
	punpckhbw xmm10, xmm11 ; 00|0r|0g|0b|00|00|00|00
	; suma horizontal de a word: como los valores son 0r 0g 0b son todos positivos 
	; y la suma en el peor caso es 510 < 32,767
	psrldq xmm10, 8 ; 00|00|00|00|00|0r|0g|0b
	pxor xmm11, xmm11
	phaddw xmm10, xmm11 ; 00+00|00+00|00+00|00+00|00+00|00+00|00+0r|0g+0b
	; otra vez: es en el peor caso 1020 < 32,767
	phaddw xmm10, xmm11 ; 00+00|00+00|00+00|00+00|00+00|00+00|00+00|00+0r+0g+0b
	; luego packear saturado.
	packuswb xmm10, xmm11 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|suma(00+0r4+0g4+0b4)
	pxor xmm12, xmm12
	movdqu xmm12, xmm10 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|suma(00+0r4+0g4+0b4)

	; pixel suma 3
	pxor xmm10, xmm10
	movdqu xmm10, xmm9 ; 0|sum(r4)|sum(g4)|sum(b4)|sum(r3)|sum(g3)|sum(b3)|sum(r2)|sum(g2)|sum(b2)|sum(r1)|sum(g1)|sum(b1)|sum(r0)|sum(g0)|sum(b0)
	pslldq xmm10, 3 ; 0|sum(r3)|sum(g3)|sum(b3)|sum(r2)|sum(g2)|sum(b2)|sum(r1)|sum(g1)|sum(b1)|sum(r0)|sum(g0)|sum(b0)|0|0|0
	pand xmm10, xmm8 ; 0|sum(r)|sum(g)|sum(b)|0|0|0|0|0|0|0|0|0|0|0|0
	pxor xmm11, xmm11
	; unpack a word 
	punpckhbw xmm10, xmm11 ; 00|0r|0g|0b|00|00|00|00
	; suma horizontal de a word: como los valores son 0r 0g 0b son todos positivos 
	; y la suma en el peor caso es 510 < 32,767
	psrldq xmm10, 8 ; 00|00|00|00|00|0r|0g|0b
	pxor xmm11, xmm11
	phaddw xmm10, xmm11 ; 00+00|00+00|00+00|00+00|00+00|00+00|00+0r|0g+0b
	; otra vez: es en el peor caso 1020 < 32,767
	phaddw xmm10, xmm11 ; 00+00|00+00|00+00|00+00|00+00|00+00|00+00|00+0r+0g+0b
	; luego packear saturado.
	packuswb xmm10, xmm11 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|suma(00+0r3+0g3+0b3)
	pslldq xmm12, 1 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|0|suma(00+0r4+0g4+0b4)|0
	por xmm12, xmm10 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|0|suma(00+0r4+0g4+0b4)|suma(00+0r3+0g3+0b3)

	; pixel suma 2
	pxor xmm10, xmm10
	movdqu xmm10, xmm9 ; 0|sum(r4)|sum(g4)|sum(b4)|sum(r3)|sum(g3)|sum(b3)|sum(r2)|sum(g2)|sum(b2)|sum(r1)|sum(g1)|sum(b1)|sum(r0)|sum(g0)|sum(b0)
	pslldq xmm10, 6 ; 0|sum(r2)|sum(g2)|sum(b2)|sum(r1)|sum(g1)|sum(b1)|sum(r0)|sum(g0)|sum(b0)|0|0|0|0|0|0
	pand xmm10, xmm8 ; 0|sum(r)|sum(g)|sum(b)|0|0|0|0|0|0|0|0|0|0|0|0
	pxor xmm11, xmm11
	; unpack a word 
	punpckhbw xmm10, xmm11 ; 00|0r|0g|0b|00|00|00|00
	; suma horizontal de a word: como los valores son 0r 0g 0b son todos positivos 
	; y la suma en el peor caso es 510 < 32,767
	psrldq xmm10, 8 ; 00|00|00|00|00|0r|0g|0b
	pxor xmm11, xmm11
	phaddw xmm10, xmm11 ; 00+00|00+00|00+00|00+00|00+00|00+00|00+0r|0g+0b
	; otra vez: es en el peor caso 1020 < 32,767
	phaddw xmm10, xmm11 ; 00+00|00+00|00+00|00+00|00+00|00+00|00+00|00+0r+0g+0b
	; luego packear saturado.
	packuswb xmm10, xmm11 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|suma(00+0r2+0g2+0b2)
	pslldq xmm12, 1 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|suma(00+0r4+0g4+0b4)|suma(00+0r3+0g3+0b3)|0
	por xmm12, xmm10 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|suma(00+0r4+0g4+0b4)|suma(00+0r3+0g3+0b3)|suma(00+0r2+0g2+0b2)

	; pixel suma 1
	pxor xmm10, xmm10
	movdqu xmm10, xmm9 ; 0|sum(r4)|sum(g4)|sum(b4)|sum(r3)|sum(g3)|sum(b3)|sum(r2)|sum(g2)|sum(b2)|sum(r1)|sum(g1)|sum(b1)|sum(r0)|sum(g0)|sum(b0)
	pslldq xmm10, 9 ; 0|sum(r1)|sum(g1)|sum(b1)|sum(r0)|sum(g0)|sum(b0)|0|0|0|0|0|0|0|0|0
	pand xmm10, xmm8 ; 0|sum(r)|sum(g)|sum(b)|0|0|0|0|0|0|0|0|0|0|0|0
	pxor xmm11, xmm11
	; unpack a word 
	punpckhbw xmm10, xmm11 ; 00|0r|0g|0b|00|00|00|00
	; suma horizontal de a word: como los valores son 0r 0g 0b son todos positivos 
	; y la suma en el peor caso es 510 < 32,767
	psrldq xmm10, 8 ; 00|00|00|00|00|0r|0g|0b
	pxor xmm11, xmm11
	phaddw xmm10, xmm11 ; 00+00|00+00|00+00|00+00|00+00|00+00|00+0r|0g+0b
	; otra vez: es en el peor caso 1020 < 32,767
	phaddw xmm10, xmm11 ; 00+00|00+00|00+00|00+00|00+00|00+00|00+00|00+0r+0g+0b
	; luego packear saturado.
	packuswb xmm10, xmm11 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|suma(00+0r1+0g1+0b1)
	pslldq xmm12, 1 ; 0|0|0|0|0|0|0|0|0|0|0|0|suma(00+0r4+0g4+0b4)|suma(00+0r3+0g3+0b3)|suma(00+0r2+0g2+0b2)|0
	por xmm12, xmm10 ; 0|0|0|0|0|0|0|0|0|0|0|0|suma(00+0r4+0g4+0b4)|suma(00+0r3+0g3+0b3)|suma(00+0r2+0g2+0b2)|suma(00+0r1+0g1+0b1)

	; pixel suma 0
	pxor xmm10, xmm10
	movdqu xmm10, xmm9 ; 0|sum(r4)|sum(g4)|sum(b4)|sum(r3)|sum(g3)|sum(b3)|sum(r2)|sum(g2)|sum(b2)|sum(r1)|sum(g1)|sum(b1)|sum(r0)|sum(g0)|sum(b0)
	pslldq xmm10, 12 ; 0|sum(r0)|sum(g0)|sum(b0)|0|0|0|0|0|0|0|0|0|0|0|0
	pand xmm10, xmm8 ; 0|sum(r)|sum(g)|sum(b)|0|0|0|0|0|0|0|0|0|0|0|0
	pxor xmm11, xmm11
	; unpack a word 
	punpckhbw xmm10, xmm11 ; 00|0r|0g|0b|00|00|00|00
	; suma horizontal de a word: como los valores son 0r 0g 0b son todos positivos 
	; y la suma en el peor caso es 510 < 32,767
	psrldq xmm10, 8 ; 00|00|00|00|00|0r|0g|0b
	pxor xmm11, xmm11
	phaddw xmm10, xmm11 ; 00+00|00+00|00+00|00+00|00+00|00+00|00+0r|0g+0b
	; otra vez: es en el peor caso 1020 < 32,767
	phaddw xmm10, xmm11 ; 00+00|00+00|00+00|00+00|00+00|00+00|00+00|00+0r+0g+0b
	; luego packear saturado.
	packuswb xmm10, xmm11 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|suma(00+0r0+0g0+0b0)
	pslldq xmm12, 1 ; 0|0|0|0|0|0|0|0|0|0|0|suma(00+0r4+0g4+0b4)|suma(00+0r3+0g3+0b3)|suma(00+0r2+0g2+0b2)|suma(00+0r1+0g1+0b1)|0
	por xmm12, xmm10 ; 0|0|0|0|0|0|0|0|0|0|0|suma(00+0r4+0g4+0b4)|suma(00+0r3+0g3+0b3)|suma(00+0r2+0g2+0b2)|suma(00+0r1+0g1+0b1)|suma(00+0r0+0g0+0b0)

	paddusb xmm13, xmm12 ; 0|0|0|0|0|0|0|0|0|0|0|suma_hasta_r10(00+0r4+0g4+0b4)|suma_hasta_r10(00+0r3+0g3+0b3)|suma_hasta_r10(00+0r2+0g2+0b2)|suma_hasta_r10(00+0r1+0g1+0b1)|suma_hasta_r10(00+0r0+0g0+0b0)

	add r12, r15
	inc r10
	cmp r10, 5
	jl .cincoEnParalelo

; xmm13  0|0|0|0|0|0|0|0|0|0|0|sumargb_i,j+4|sumargb_i,j+3|sumargb_i,j+2|sumargb_i,j+1|sumargb_i,j

; por cada pixel valido  en xmm13 procedo a calcular la formula:
; primero calculo suma(r+g+b)*Lij como un producto no signado en float (b->w->dw->pf).
; Luego multiplico por el alpha extendido a float como un producto signado. 
; Luego realizo la division por MAX como una division signada en float
; Por ultimo realizo la suma con Lij como una suma signada de floats y luego saturo hasta byte.

	pxor xmm2, xmm2
	pxor xmm1, xmm1
	;movd xmm2, rbx ; 0|0|0|alpha
	cvtsi2ss xmm2, ebx ; cast to float!
	movdqu xmm1, xmm2 ; 0|0|0|alpha
	pslldq xmm1, 4 ; 0|0|alpha|0
	por xmm1, xmm2 ; 0|0|alpha|alpha
	pslldq xmm1, 4 ; 0|alpha|alpha|0
	por xmm1, xmm2 ; 0|alpha|alpha|alpha

	pxor xmm3, xmm3
	pxor xmm2, xmm2
	;movd xmm3, r13 ; 0|0|0|max
	cvtsi2ss xmm3, r13d ; cast to float! 
	movdqu xmm2, xmm3 ; 0|0|0|max
	pslldq xmm2, 4 ; 0|0|max|0
	por xmm2, xmm3 ; 0|0|max|max
	pslldq xmm4, 4 ; 0|max|max|0
	por xmm2, xmm3 ; 0|max|max|max

	cmp r9, r11
	jge .mayorIgAColsToProccess ; mayor igual a colsToProccess

	pxor xmm10, xmm10
	pxor xmm14, xmm14
	movdqu xmm14, xmm13 ; 0|0|0|0|0|0|0|0|0|0|0|sumargb_i,j+4|sumargb_i,j+3|sumargb_i,j+2|sumargb_i,j+1|sumargb_i,j
	psrldq xmm8, 3 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|FF
	pand xmm14, xmm8 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|sumargb_i,j
	pxor xmm11, xmm11
	por xmm11, xmm14 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|sumargb_i,j
	pslldq xmm11, 1 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|0|sumargb_i,j|0
	por xmm11, xmm14 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|0|sumargb_i,j|sumargb_i,j
	pslldq xmm11, 1 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|sumargb_i,j|sumargb_i,j|0
	por xmm11, xmm14 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|sumargb_i,j|sumargb_i,j|sumargb_i,j
	pxor xmm14, xmm14
	punpcklbw xmm11, xmm14 ; 0|0|0|0|0|sumargb_i,j|sumargb_i,j|sumargb_i,j
	punpcklwd xmm11, xmm14 ; 0|sumargb_i,j|sumargb_i,j|sumargb_i,j
	cvtdq2ps xmm11, xmm11 ; cast to float!
	pxor xmm14, xmm14
	movd xmm14, [rdi + r8*4] ; 0|0|0|0|0|0|0|0|0|0|0|0|aj|rj|gj|bj <- get pixel ij
	pxor xmm0, xmm0
	movdqu xmm0, xmm14 ; 0|0|0|0|0|0|0|0|0|0|0|0|aj|rj|gj|bj
	pand xmm0, xmm15 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|rj|gj|bj
	pxor xmm3, xmm3
	punpcklbw xmm0, xmm3 ; 0|0|0|0|0|rj|gj|bj
	punpcklwd xmm0, xmm3 ; 0|rj|gj|bj
	cvtdq2ps xmm0, xmm0 ; cast to float!
;	mulps xmm11, xmm0 ; 0|sumargb_i,j*rj|sumargb_i,j*gj|sumargb_i,j*bj
;	mulps xmm11, xmm1 ; 0|alpha*sumargb_i,j*rj|alpha*sumargb_i,j*gj|alpha*sumargb_i,j*bj <- puede cambiar el signo segun alpha.
;	divps xmm11, xmm2 ; 0|(alpha*sumargb_i,j*rj)/max|(alpha*sumargb_i,j*gj)/max|(alpha*sumargb_i,j*bj)/max
;	addps xmm11, xmm0 ; 0|rj+(alpha*sumargb_i,j*rj)/max|gj+(alpha*sumargb_i,j*gj)/max|bj+(alpha*sumargb_i,j*bj)/max
	
	cvttps2dq xmm11, xmm11 ; cast to dw signed 
	pxor xmm3, xmm3
	packusdw xmm11, xmm3 ; 0|0|0|0|0|rj+(alpha*sumargb_i,j*rj)/gj+max|(alpha*sumargb_i,j*gj)/bj+max|(alpha*sumargb_i,j*bj)/max
	packuswb xmm11, xmm3 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|rj+(alpha*sumargb_i,j*rj)/gj+max|(alpha*sumargb_i,j*gj)/bj+max|(alpha*sumargb_i,j*bj)/max <- tengo los canales calculados saturados a byte.
	pslldq xmm8, 3 ; 0|0|0|0|0|0|0|0|0|0|0|FF||0|0|0
	pand xmm14, xmm8 ; 0|0|0|0|0|0|0|0|0|0|0|0|aj|0|0|0
	por xmm14, xmm11 ; 0|0|0|0|0|0|0|0|0|0|0|0|aj|rj+(alpha*sumargb_i,j*rj)/max|gj+(alpha*sumargb_i,j*gj)/max|bj+(alpha*sumargb_i,j*bj)/max

    movd [rsi + r8*4], xmm14

	inc r9
	inc r8
	cmp r9, r11
	jge .mayorIgAColsToProccess ; mayor igual a colsToProccess

	pxor xmm14, xmm14
	movdqu xmm14, xmm13 ; 0|0|0|0|0|0|0|0|0|0|0|sumargb_i,j+4|sumargb_i,j+3|sumargb_i,j+2|sumargb_i,j+1|sumargb_i,j
	pslldq xmm8, 1 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|0|FF|0
	pand xmm14, xmm8 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|0|sumargb_i,j+1|0
	pxor xmm11, xmm11
	por xmm11, xmm14 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|0|sumargb_i,j+1|0
	psrldq xmm14, 1 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|sumargb_i,j+1
	por xmm11, xmm14 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|0|sumargb_i,j+1|sumargb_i,j+1
	pslldq xmm11, 1 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|sumargb_i,j+1|sumargb_i,j+1|0
	por xmm11, xmm14 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|sumargb_i,j+1|sumargb_i,j+1|sumargb_i,j+1
	pxor xmm14, xmm14
	punpcklbw xmm11, xmm14 ; 0|0|0|0|0|sumargb_i,j+1|sumargb_i,j+1|sumargb_i,j+1
	punpcklwd xmm11, xmm14 ; 0|sumargb_i,j+1|sumargb_i,j+1|sumargb_i,j+1
	cvtdq2ps xmm11, xmm11 ; cast to float!
	pxor xmm14, xmm14
	movd xmm14, [rdi + r8*4] ; 0|0|0|0|0|0|0|0|0|0|0|0|aj+1|rj+1|gj+1|bj+1 <- get pixel ij+1
	pxor xmm0, xmm0
	movdqu xmm0, xmm14 ; 0|0|0|0|0|0|0|0|0|0|0|0|aj+1|rj+1|gj+1|bj+1
	pand xmm0, xmm15 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|rj+1|gj+1|bj+1
	pxor xmm3, xmm3
	punpcklbw xmm0, xmm3 ; 0|0|0|0|0|rj+1|gj+1|bj+1
	punpcklwd xmm0, xmm3 ; 0|rj+1|gj+1|bj+1
	cvtdq2ps xmm0, xmm0 ; cast to float!
;	mulps xmm11, xmm0 ; 0|sumargb_i,j+1*rj+1|sumargb_i,j+1*gj+1|sumargb_i,j+1*bj+1
;	mulps xmm11, xmm1 ; 0|alpha*sumargb_i,j+1*rj+1|alpha*sumargb_i,j+1*gj+1|alpha*sumargb_i,j+1*bj+1 <- puede cambiar el signo segun alpha.
;	divps xmm11, xmm2 ; 0|(alpha*sumargb_i,j+1*rj+1)/max|(alpha*sumargb_i,j+1*gj+1)/max|(alpha*sumargb_i,j+1*bj+1)/max
;	addps xmm11, xmm0 ; 0|rj+1+(alpha*sumargb_i,j+1*rj+1)/max|gj+1+(alpha*sumargb_i,j+1*gj+1)/max|bj+1+(alpha*sumargb_i,j+1*bj+1)/max
	
	cvttps2dq xmm11, xmm11 ; cast to dw signed 
	pxor xmm3, xmm3
	packusdw xmm11, xmm3 ; 0|0|0|0|0|rj+1+(alpha*sumargb_i,j+1*rj+1)/gj+1+max|(alpha*sumargb_i,j+1*gj+1)/bj+1+max|(alpha*sumargb_i,j+1*bj+1)/max
	packuswb xmm11, xmm3 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|rj+1+(alpha*sumargb_i,j+1*rj+1)/gj+1+max|(alpha*sumargb_i,j+1*gj+1)/bj+1+max|(alpha*sumargb_i,j+1*bj+1)/max <- tengo los canales calculados saturados a byte.
	pslldq xmm8, 3 ; 0|0|0|0|0|0|0|0|0|0|0|FF||0|0|0
	pand xmm14, xmm8 ; 0|0|0|0|0|0|0|0|0|0|0|0|aj+1|0|0|0
	por xmm14, xmm11 ; 0|0|0|0|0|0|0|0|0|0|0|0|aj+1|rj+1+(alpha*sumargb_i,j+1*rj+1)/max|gj+1+(alpha*sumargb_i,j+1*gj+1)/max|bj+1+(alpha*sumargb_i,j+1*bj+1)/max

    movd [rsi + r8*4], xmm14

	inc r9
	inc r8
	cmp r9, r11
	jge .mayorIgAColsToProccess ; mayor igual a colsToProccess

	pxor xmm14, xmm14
	movdqu xmm14, xmm13 ; 0|0|0|0|0|0|0|0|0|0|0|sumargb_i,j+4|sumargb_i,j+3|sumargb_i,j+2|sumargb_i,j+1|sumargb_i,j
	pslldq xmm8, 1 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|FF|0|0
	pand xmm14, xmm8 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|sumargb_i,j+1|0|0
	pxor xmm11, xmm11
	por xmm11, xmm14 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|sumargb_i,j+1|0|0
	psrldq xmm14, 1 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|0|sumargb_i,j+1|0
	por xmm11, xmm14 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|sumargb_i,j+1|sumargb_i,j+1|0
	psrldq xmm14, 1 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|sumargb_i,j+1
	por xmm11, xmm14 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|sumargb_i,j+1|sumargb_i,j+1|sumargb_i,j+1
	pxor xmm14, xmm14
	punpcklbw xmm11, xmm14 ; 0|0|0|0|0|sumargb_i,j+1|sumargb_i,j+1|sumargb_i,j+1
	punpcklwd xmm11, xmm14 ; 0|sumargb_i,j+1|sumargb_i,j+1|sumargb_i,j+1
	cvtdq2ps xmm11, xmm11 ; cast to float!
	pxor xmm14, xmm14
	movd xmm14, [rdi + r8*4] ; 0|0|0|0|0|0|0|0|0|0|0|0|aj+1|rj+1|gj+1|bj+1 <- get pixel ij+1
	pxor xmm0, xmm0
	movdqu xmm0, xmm14 ; 0|0|0|0|0|0|0|0|0|0|0|0|aj+1|rj+1|gj+1|bj+1
	pand xmm0, xmm15 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|rj+1|gj+1|bj+1
	pxor xmm3, xmm3
	punpcklbw xmm0, xmm3 ; 0|0|0|0|0|rj+1|gj+1|bj+1
	punpcklwd xmm0, xmm3 ; 0|rj+1|gj+1|bj+1
	cvtdq2ps xmm0, xmm0 ; cast to float!
	mulps xmm11, xmm0 ; 0|sumargb_i,j+1*rj+1|sumargb_i,j+1*gj+1|sumargb_i,j+1*bj+1
	mulps xmm11, xmm1 ; 0|alpha*sumargb_i,j+1*rj+1|alpha*sumargb_i,j+1*gj+1|alpha*sumargb_i,j+1*bj+1 <- puede cambiar el signo segun alpha.
	divps xmm11, xmm2 ; 0|(alpha*sumargb_i,j+1*rj+1)/max|(alpha*sumargb_i,j+1*gj+1)/max|(alpha*sumargb_i,j+1*bj+1)/max
	addps xmm11, xmm0 ; 0|rj+1+(alpha*sumargb_i,j+1*rj+1)/max|gj+1+(alpha*sumargb_i,j+1*gj+1)/max|bj+1+(alpha*sumargb_i,j+1*bj+1)/max
	
	cvttps2dq xmm11, xmm11 ; cast to dw signed 
	pxor xmm3, xmm3
	packusdw xmm11, xmm3 ; 0|0|0|0|0|rj+1+(alpha*sumargb_i,j+1*rj+1)/gj+1+max|(alpha*sumargb_i,j+1*gj+1)/bj+1+max|(alpha*sumargb_i,j+1*bj+1)/max
	packuswb xmm11, xmm3 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|rj+1+(alpha*sumargb_i,j+1*rj+1)/gj+1+max|(alpha*sumargb_i,j+1*gj+1)/bj+1+max|(alpha*sumargb_i,j+1*bj+1)/max <- tengo los canales calculados saturados a byte.
	pslldq xmm8, 3 ; 0|0|0|0|0|0|0|0|0|0|0|FF||0|0|0
;	pand xmm14, xmm8 ; 0|0|0|0|0|0|0|0|0|0|0|0|aj+1|0|0|0
;	por xmm14, xmm11 ; 0|0|0|0|0|0|0|0|0|0|0|0|aj+1|rj+1+(alpha*sumargb_i,j+1*rj+1)/max|gj+1+(alpha*sumargb_i,j+1*gj+1)/max|bj+1+(alpha*sumargb_i,j+1*bj+1)/max

    movd [rsi + r8*4], xmm14

	inc r9
	inc r8
	cmp r9, r11
	jge .mayorIgAColsToProccess ; mayor igual a colsToProccess

	pxor xmm14, xmm14
	movdqu xmm14, xmm13 ; 0|0|0|0|0|0|0|0|0|0|0|sumargb_i,j+4|sumargb_i,j+3|sumargb_i,j+2|sumargb_i,j+1|sumargb_i,j
	pslldq xmm8, 1 ; 0|0|0|0|0|0|0|0|0|0|0|0|FF|0|0|0
	pand xmm14, xmm8 ; 0|0|0|0|0|0|0|0|0|0|0|0|sumargb_i,j+1|0|0|0
	pxor xmm11, xmm11
	psrldq xmm14, 1 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|sumargb_i,j+1|0|0
	por xmm11, xmm14 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|sumargb_i,j+1|0|0
	psrldq xmm11, 1 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|0|sumargb_i,j+1|0
	por xmm11, xmm14 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|sumargb_i,j+1|sumargb_i,j+1|0
	psrldq xmm14, 2 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|sumargb_i,j+1
	por xmm11, xmm14 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|sumargb_i,j+1|sumargb_i,j+1|sumargb_i,j+1
	pxor xmm14, xmm14
	punpcklbw xmm11, xmm14 ; 0|0|0|0|0|sumargb_i,j+1|sumargb_i,j+1|sumargb_i,j+1
	punpcklwd xmm11, xmm14 ; 0|sumargb_i,j+1|sumargb_i,j+1|sumargb_i,j+1
	cvtdq2ps xmm11, xmm11 ; cast to float!
	pxor xmm14, xmm14
	movd xmm14, [rdi + r8*4] ; 0|0|0|0|0|0|0|0|0|0|0|0|aj+1|rj+1|gj+1|bj+1 <- get pixel ij+1
	pxor xmm0, xmm0
	movdqu xmm0, xmm14 ; 0|0|0|0|0|0|0|0|0|0|0|0|aj+1|rj+1|gj+1|bj+1
	pand xmm0, xmm15 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|rj+1|gj+1|bj+1
	pxor xmm3, xmm3
	punpcklbw xmm0, xmm3 ; 0|0|0|0|0|rj+1|gj+1|bj+1
	punpcklwd xmm0, xmm3 ; 0|rj+1|gj+1|bj+1
	cvtdq2ps xmm0, xmm0 ; cast to float!
	mulps xmm11, xmm0 ; 0|sumargb_i,j+1*rj+1|sumargb_i,j+1*gj+1|sumargb_i,j+1*bj+1
	mulps xmm11, xmm1 ; 0|alpha*sumargb_i,j+1*rj+1|alpha*sumargb_i,j+1*gj+1|alpha*sumargb_i,j+1*bj+1 <- puede cambiar el signo segun alpha.
	divps xmm11, xmm2 ; 0|(alpha*sumargb_i,j+1*rj+1)/max|(alpha*sumargb_i,j+1*gj+1)/max|(alpha*sumargb_i,j+1*bj+1)/max
	addps xmm11, xmm0 ; 0|rj+1+(alpha*sumargb_i,j+1*rj+1)/max|gj+1+(alpha*sumargb_i,j+1*gj+1)/max|bj+1+(alpha*sumargb_i,j+1*bj+1)/max
	
	cvttps2dq xmm11, xmm11 ; cast to dw signed 
	pxor xmm3, xmm3
	packusdw xmm11, xmm3 ; 0|0|0|0|0|rj+1+(alpha*sumargb_i,j+1*rj+1)/gj+1+max|(alpha*sumargb_i,j+1*gj+1)/bj+1+max|(alpha*sumargb_i,j+1*bj+1)/max
	packuswb xmm11, xmm3 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|rj+1+(alpha*sumargb_i,j+1*rj+1)/gj+1+max|(alpha*sumargb_i,j+1*gj+1)/bj+1+max|(alpha*sumargb_i,j+1*bj+1)/max <- tengo los canales calculados saturados a byte.
	pslldq xmm8, 3 ; 0|0|0|0|0|0|0|0|0|0|0|FF||0|0|0
;	pand xmm14, xmm8 ; 0|0|0|0|0|0|0|0|0|0|0|0|aj+1|0|0|0
;	por xmm14, xmm11 ; 0|0|0|0|0|0|0|0|0|0|0|0|aj+1|rj+1+(alpha*sumargb_i,j+1*rj+1)/max|gj+1+(alpha*sumargb_i,j+1*gj+1)/max|bj+1+(alpha*sumargb_i,j+1*bj+1)/max

    movd [rsi + r8*4], xmm14

	inc r9
	inc r8
	cmp r9, r11
	jge .mayorIgAColsToProccess ; mayor igual a colsToProccess

	pxor xmm14, xmm14
	movdqu xmm14, xmm13 ; 0|0|0|0|0|0|0|0|0|0|0|sumargb_i,j+4|sumargb_i,j+3|sumargb_i,j+2|sumargb_i,j+1|sumargb_i,j
	pslldq xmm8, 1 ; 0|0|0|0|0|0|0|0|0|0|0|0|FF|0|0|0
	pand xmm14, xmm8 ; 0|0|0|0|0|0|0|0|0|0|0|0|sumargb_i,j+1|0|0|0
	pxor xmm11, xmm11
	psrldq xmm14, 1 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|sumargb_i,j+1|0|0
	por xmm11, xmm14 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|sumargb_i,j+1|0|0
	psrldq xmm11, 1 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|0|sumargb_i,j+1|0
	por xmm11, xmm14 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|sumargb_i,j+1|sumargb_i,j+1|0
	psrldq xmm14, 2 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|sumargb_i,j+1
	por xmm11, xmm14 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|sumargb_i,j+1|sumargb_i,j+1|sumargb_i,j+1
	pxor xmm14, xmm14
	punpcklbw xmm11, xmm14 ; 0|0|0|0|0|sumargb_i,j+1|sumargb_i,j+1|sumargb_i,j+1
	punpcklwd xmm11, xmm14 ; 0|sumargb_i,j+1|sumargb_i,j+1|sumargb_i,j+1
	cvtdq2ps xmm11, xmm11 ; cast to float!
	pxor xmm14, xmm14
	movd xmm14, [rdi + r8*4] ; 0|0|0|0|0|0|0|0|0|0|0|0|aj+1|rj+1|gj+1|bj+1 <- get pixel ij+1
	pxor xmm0, xmm0
	movdqu xmm0, xmm14 ; 0|0|0|0|0|0|0|0|0|0|0|0|aj+1|rj+1|gj+1|bj+1
	pand xmm0, xmm15 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|rj+1|gj+1|bj+1
	pxor xmm3, xmm3
	punpcklbw xmm0, xmm3 ; 0|0|0|0|0|rj+1|gj+1|bj+1
	punpcklwd xmm0, xmm3 ; 0|rj+1|gj+1|bj+1
	cvtdq2ps xmm0, xmm0 ; cast to float!
	mulps xmm11, xmm0 ; 0|sumargb_i,j+1*rj+1|sumargb_i,j+1*gj+1|sumargb_i,j+1*bj+1
	mulps xmm11, xmm1 ; 0|alpha*sumargb_i,j+1*rj+1|alpha*sumargb_i,j+1*gj+1|alpha*sumargb_i,j+1*bj+1 <- puede cambiar el signo segun alpha.
	divps xmm11, xmm2 ; 0|(alpha*sumargb_i,j+1*rj+1)/max|(alpha*sumargb_i,j+1*gj+1)/max|(alpha*sumargb_i,j+1*bj+1)/max
	addps xmm11, xmm0 ; 0|rj+1+(alpha*sumargb_i,j+1*rj+1)/max|gj+1+(alpha*sumargb_i,j+1*gj+1)/max|bj+1+(alpha*sumargb_i,j+1*bj+1)/max
	
	cvttps2dq xmm11, xmm11 ; cast to dw signed 
	pxor xmm3, xmm3
	packusdw xmm11, xmm3 ; 0|0|0|0|0|rj+1+(alpha*sumargb_i,j+1*rj+1)/gj+1+max|(alpha*sumargb_i,j+1*gj+1)/bj+1+max|(alpha*sumargb_i,j+1*bj+1)/max
	packuswb xmm11, xmm3 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|rj+1+(alpha*sumargb_i,j+1*rj+1)/gj+1+max|(alpha*sumargb_i,j+1*gj+1)/bj+1+max|(alpha*sumargb_i,j+1*bj+1)/max <- tengo los canales calculados saturados a byte.
	pslldq xmm8, 3 ; 0|0|0|0|0|0|0|0|0|0|0|FF||0|0|0
;	pand xmm14, xmm8 ; 0|0|0|0|0|0|0|0|0|0|0|0|aj+1|0|0|0
;	por xmm14, xmm11 ; 0|0|0|0|0|0|0|0|0|0|0|0|aj+1|rj+1+(alpha*sumargb_i,j+1*rj+1)/max|gj+1+(alpha*sumargb_i,j+1*gj+1)/max|bj+1+(alpha*sumargb_i,j+1*bj+1)/max

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
	pslldq xmm8, 1 ; 0|0|0|0|0|0|0|0|0|0|0|0|FF|FF|FF|0
	cmp r8, rcx
	jl .ciclo

.sinCambios:
	xor r8, r8
	xor r9, r9
	mov r9, rcx ; columnas*filas
	shl r15, 1 ; r15*2
	sub r9, r15 ; ante-ultima fila, posicion 0
.devolver:
	pxor xmm10, xmm10
	pxor xmm11, xmm11
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
