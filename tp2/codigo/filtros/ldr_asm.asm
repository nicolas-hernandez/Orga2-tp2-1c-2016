global ldr_asm

section .data
DEFAULT REL

%define WHITE 255
%define BLACK 0

; En memoria: BGRA
; En registros: ARGB

; a3|r3|g3|b3|a2|r2|g2|b2|a1|r1|g1|b1|a0|r0|g0|b0 -> a3|a2|a1|a0|r3|g3|b3|r2|g2|b2|r1|g1|b1|r0|g0|b0
juntarCanalesAlpha: db 0x00, 0x01, 0x02, 0x0C, 0x03, 0x04, 0x05, 0x0D, 0x06, 0x07, 0x08, 0x0E, 0x09, 0x0A, 0x0B, 0x0F 
limpiarCanalesAlpha: db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00
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
	push r12 ;
	push r13 ;
	push r14 ;
	push r15 ;
	sub rsp, 8 ; alineado

	xor r12, r12
	xor r13, r13
	xor r14, r14

	cmp ebx, -255
	jl .terminar
	cmp ebx, 255
	jg .terminar
	cmp edx, 4
	jle .terminar ; si tengo menos de cuatro filas terminar.
	cmp ecx, 4
	jle .terminar ; si tengo menos que cuatro columnas terminar.

	xor r8, r8 ; posicion actual
	xor r9, r9 ; j = 0
	mov r8d, ecx ; r8 = columnas

	xor r15, r15
	mov r15d, ecx ; r15d = columnas 
	xor rcx, rcx
	xor r11, r11
	mov r11d, edx ; r11d = filas 
	xor rax, rax ; limpio para usar en multiplicacion.
	mov eax, r15d
	mul r11d ; edx:eax = r15d*r11d = columnas*filas.
	mov ecx, edx
	shl rdx, 32
	mov ecx, eax ; ecx = r15d*r11d = columnas*filas. contador loop.

	xor rdx, rdx ; parte alta - resto 
	xor rax, rax ; parte baja - cociente.
	mov eax, r15d
	mov edx, 2
	div edx ; divido columnas por dos - resto en edx (from 0 to 1) 
	cmp edx, 1 ; tambien podria haber usado que la division setea el flag de paridad pf?.
	jne .esPar
	sub r15d, 1 ; es impar. La ultima columna no se procesa.
.esPar:
	sub r15d, 2 ; (columnas-resto)-2 = colsToProccess

; devolver las primeras dos filas tal cual estan. Desde rdi la fila 0 y desde rdi+r8 la fila 1
; devolver la ultima fila tal cual esta. Desde rcx-r8

	shl r8, 1 ; i = 2 - j = 0

; devolver la ante-ultima fila tal cual esta. Desde rcx-r8*2 <- paso anterior

	movdqu xmm6, [juntarCanalesAlpha]
	movdqu xmm7, [limpiarCanalesAlpha]
	movdqu xmm8, [salvarUnPixelShifteable]

.ciclo: ; while(r8 < rcx) == (actual < total) 
; if(j > 1)
	cmp r9, 2
	jl .menorAColDos
	; estoy en rango.
	mov r11, r15
	add r11, 2
	add r11, edx ; columnas totales.
	mov r14, r8 ; posicion actual
	sub r14, r11
	sub r14, r11 ; posicion actual - dos filas
	xor r10, r10 ; cuento hasta 5

	pxor xmm14, xmm14 ; acumulo la suma de los cuadrados de 5 pixeles.
.cincoEnParalelo: ; Puedo procesar 5 pixeles en paralelo - los pixeles que estan en columnas mayores a colsToProccess no se tendran en cuenta.
	; me corro -2 posiciones
	mov r13, r14
	sub r13, 2
	
	;          20  16  12   8   4   0
	; Li7|Li6|Li5|Li4|Li3|Li2|Li1|Li0

	movdqu xmm0, [rdi + r13*4] ; Li3|Li2|Li1|Li0
	pshufb xmm0, xmm6 ; a3|a2|a1|a0|r3|g3|b3|r2|g2|b2|r1|g1|b1|r0|g0|b0
	pand xmm0, xmm7 ; 0|0|0|0|r3|g3|b3|r2|g2|b2|r1|g1|b1|r0|g0|b0
	
	movdqu xmm1, [rdi + r13*4 + 4] ; Li4|Li3|Li2|Li1
	pshufb xmm1, xmm6 ; a4|a3|a2|a1|r4|g4|b4|r3|g3|b3|r2|g2|b2|r1|g1|b1
	pand xmm1, xmm7 ; 0|0|0|0|r4|g4|b4|r3|g3|b3|r2|g2|b2|r1|g1|b1
	
	pxor xmm9, xmm9
	movdqu xmm9, xmm1
	pslldq xmm9, 3 ; 0|r4|g4|b4|r3|g3|b3|r2|g2|b2|r1|g1|b1|0|0|0
	pand xmm9, xmm8 ; 0|r4|g4|b4|0|0|0|0|0|0|0|0|0|0|0|0
	por xmm0, xmm9 ; 0|r4|g4|b4|r3|g3|b3|r2|g2|b2|r1|g1|b1|r0|g0|b0

	movdqu xmm2, [rdi + r13*4 + 8] ; Li5|Li4|Li3|Li2
	pshufb xmm2, xmm6 ; a5|a4|a3|a2|r5|g5|b5|r4|g4|b4|r3|g3|b3|r2|g2|b2
	pand xmm2, xmm7 ; 0|0|0|0|r5|g5|b5|r4|g4|b4|r3|g3|b3|r2|g2|b2
	
	pxor xmm9, xmm9
	movdqu xmm9, xmm2
	pslldq xmm9, 3 ; 0|r5|g5|b5|r4|g4|b4|r3|g3|b3|r2|g2|b2|0|0|0
	pand xmm9, xmm8 ; 0|r5|g5|b5|0|0|0|0|0|0|0|0|0|0|0|0
	por xmm1, xmm9 ; 0|r5|g5|b5|r4|g4|b4|r3|g3|b3|r2|g2|b2|r1|g1|b1

	movdqu xmm3, [rdi + r13*4 + 12] ; Li6|Li5|Li4|Li3
	pshufb xmm3, xmm6 ; a6|a5|a4|a3|r6|g6|b6|r5|g5|b5|r4|g4|b4|r3|g3|b3
	pand xmm3, xmm7 ; 0|0|0|0|r6|g6|b6|r5|g5|b5|r4|g4|b4|r3|g3|b3
	
	pxor xmm9, xmm9
	movdqu xmm9, xmm3
	pslldq xmm9, 3 ; 0|r6|g6|b6|r5|g5|b5|r4|g4|b4|r3|g3|b3|0|0|0
	pand xmm9, xmm8 ; 0|r6|g6|b6|0|0|0|0|0|0|0|0|0|0|0|0
	por xmm2, xmm9 ; 0|r6|g6|b6|r5|g5|b5|r4|g4|b4|r3|g3|b3|r2|g2|b2

	movdqu xmm4, [rdi + r13*4 + 16] ; Li7|Li6|Li5|Li4
	pshufb xmm4, xmm6 ; a7|a6|a5|a4|r7|g7|b7|r6|g6|b6|r5|g5|b5|r4|g4|b4
	pand xmm4, xmm7 ; 0|0|0|0|r7|g7|b7|r6|g6|b6|r5|g5|b5|r4|g4|b4
	
	pxor xmm9, xmm9
	movdqu xmm9, xmm4
	pslldq xmm9, 3 ; 0|r7|g7|b7|r6|g6|b6|r5|g5|b5|r4|g4|b4|0|0|0
	pand xmm9, xmm8 ; 0|r7|g7|b7|0|0|0|0|0|0|0|0|0|0|0|0
	por xmm3, xmm9 ; 0|r7|g7|b7|r6|g6|b6|r5|g5|b5|r4|g4|b4|r3|g3|b3

	pxor xmm9, xmm9
	movd xmm9, [rdi + r13*4 + 20] ; 0|0|0|0|0|0|0|0|0|0|0|0|a8|r8|g8|b8
	pslldq xmm9, 12 ; a8|r8|g8|b8|0|0|0|0|0|0|0|0|0|0|0|0
	pand xmm9, xmm8 ; 0|r8|g8|b8|0|0|0|0|0|0|0|0|0|0|0|0
	por xmm4, xmm9 ; 0|r8|g8|b8|r7|g7|b7|r6|g6|b6|r5|g5|b5|r4|g4|b4

	; realizar suma vertical de bytes saturada y acumular en xmm10, 
	pxor xmm10, xmm10
	paddusb xmm10, xmm0
	paddusb xmm10, xmm1
	paddusb xmm10, xmm2
	paddusb xmm10, xmm3
	paddusb xmm10, xmm4 ; 0|sum(r4)|sum(g4)|sum(b4)|sum(r3)|sum(g3)|sum(b3)|sum(r2)|sum(g2)|sum(b2)|sum(r1)|sum(g1)|sum(b1)|sum(r0)|sum(g0)|sum(b0)

	; pixel suma 4
	; mascara: xmm8
	pxor xmm11, xmm11
	movdqu xmm11, xmm10 ; 0|sum(r4)|sum(g4)|sum(b4)|sum(r3)|sum(g3)|sum(b3)|sum(r2)|sum(g2)|sum(b2)|sum(r1)|sum(g1)|sum(b1)|sum(r0)|sum(g0)|sum(b0)
	pand xmm11, xmm8 ; 0|sum(r)|sum(g)|sum(b)|0|0|0|0|0|0|0|0|0|0|0|0
	pxor xmm12, xmm12
	; unpack a word 
	punpckhbw xmm11, xmm12 ; 00|0r|0g|0b|00|00|00|00
	; suma horizontal de a word: como los valores son 0r 0g 0b son todos positivos 
	; y la suma en el peor caso es 510 < 32,767
	phaddw xmm11, xmm12 ; 00+00|00+00|00+00|00+00|00+00|00+00|00+0r|0g+0b
	; otra vez: es en el peor caso 1020 < 32,767
	phaddw xmm11, xmm12 ; 00+00|00+00|00+00|00+00|00+00|00+00|00+00|00+0r+0g+0b
	; luego packear saturado.
	packuswb xmm11, xmm12 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|suma(00+0r+0g+0b)
	pxor xmm13, xmm13
	movdqu xmm13, xmm11 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|suma(00+0r+0g+0b)

	; pixel suma 3
	pxor xmm11, xmm11
	movdqu xmm11, xmm10 ; 0|sum(r4)|sum(g4)|sum(b4)|sum(r3)|sum(g3)|sum(b3)|sum(r2)|sum(g2)|sum(b2)|sum(r1)|sum(g1)|sum(b1)|sum(r0)|sum(g0)|sum(b0)
	pslldq xmm11, 3 ; 0|sum(r3)|sum(g3)|sum(b3)|sum(r2)|sum(g2)|sum(b2)|sum(r1)|sum(g1)|sum(b1)|sum(r0)|sum(g0)|sum(b0)|0|0|0
	pand xmm11, xmm8 ; 0|sum(r)|sum(g)|sum(b)|0|0|0|0|0|0|0|0|0|0|0|0
	pxor xmm12, xmm12
	; unpack a word 
	punpckhbw xmm11, xmm12 ; 00|0r|0g|0b|00|00|00|00
	; suma horizontal de a word: como los valores son 0r 0g 0b son todos positivos 
	; y la suma en el peor caso es 510 < 32,767
	phaddw xmm11, xmm12 ; 00+00|00+00|00+00|00+00|00+00|00+00|00+0r|0g+0b
	; otra vez: es en el peor caso 1020 < 32,767
	phaddw xmm11, xmm12 ; 00+00|00+00|00+00|00+00|00+00|00+00|00+00|00+0r+0g+0b
	; luego packear saturado.
	packuswb xmm11, xmm12 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|suma(00+0r4+0g4+0b4)
	pslldq xmm13, 1 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|0|suma(00+0r4+0g4+0b4)|0
	por xmm13, xmm11 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|0|suma(00+0r4+0g4+0b4)|suma(00+0r3+0g3+0b3)

	; pixel suma 2
	pxor xmm11, xmm11
	movdqu xmm11, xmm10 ; 0|sum(r4)|sum(g4)|sum(b4)|sum(r3)|sum(g3)|sum(b3)|sum(r2)|sum(g2)|sum(b2)|sum(r1)|sum(g1)|sum(b1)|sum(r0)|sum(g0)|sum(b0)
	pslldq xmm11, 6 ; 0|sum(r2)|sum(g2)|sum(b2)|sum(r1)|sum(g1)|sum(b1)|sum(r0)|sum(g0)|sum(b0)|0|0|0|0|0|0
	pand xmm11, xmm8 ; 0|sum(r)|sum(g)|sum(b)|0|0|0|0|0|0|0|0|0|0|0|0
	pxor xmm12, xmm12
	; unpack a word 
	punpckhbw xmm11, xmm12 ; 00|0r|0g|0b|00|00|00|00
	; suma horizontal de a word: como los valores son 0r 0g 0b son todos positivos 
	; y la suma en el peor caso es 510 < 32,767
	phaddw xmm11, xmm12 ; 00+00|00+00|00+00|00+00|00+00|00+00|00+0r|0g+0b
	; otra vez: es en el peor caso 1020 < 32,767
	phaddw xmm11, xmm12 ; 00+00|00+00|00+00|00+00|00+00|00+00|00+00|00+0r+0g+0b
	; luego packear saturado.
	packuswb xmm11, xmm12 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|suma(00+0r2+0g2+0b2)
	pslldq xmm13, 1 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|suma(00+0r4+0g4+0b4)|suma(00+0r3+0g3+0b3)|0
	por xmm13, xmm11 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|suma(00+0r4+0g4+0b4)|suma(00+0r3+0g3+0b3)|suma(00+0r2+0g2+0b2)

	; pixel suma 1
	pxor xmm11, xmm11
	movdqu xmm11, xmm10 ; 0|sum(r4)|sum(g4)|sum(b4)|sum(r3)|sum(g3)|sum(b3)|sum(r2)|sum(g2)|sum(b2)|sum(r1)|sum(g1)|sum(b1)|sum(r0)|sum(g0)|sum(b0)
	pslldq xmm11, 9 ; 0|sum(r1)|sum(g1)|sum(b1)|sum(r0)|sum(g0)|sum(b0)|0|0|0|0|0|0|0|0|0
	pand xmm11, xmm8 ; 0|sum(r)|sum(g)|sum(b)|0|0|0|0|0|0|0|0|0|0|0|0
	pxor xmm12, xmm12
	; unpack a word 
	punpckhbw xmm11, xmm12 ; 00|0r|0g|0b|00|00|00|00
	; suma horizontal de a word: como los valores son 0r 0g 0b son todos positivos 
	; y la suma en el peor caso es 510 < 32,767
	phaddw xmm11, xmm12 ; 00+00|00+00|00+00|00+00|00+00|00+00|00+0r|0g+0b
	; otra vez: es en el peor caso 1020 < 32,767
	phaddw xmm11, xmm12 ; 00+00|00+00|00+00|00+00|00+00|00+00|00+00|00+0r+0g+0b
	; luego packear saturado.
	packuswb xmm11, xmm12 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|suma(00+0r1+0g1+0b1)
	pslldq xmm13, 1 ; 0|0|0|0|0|0|0|0|0|0|0|0|suma(00+0r4+0g4+0b4)|suma(00+0r3+0g3+0b3)|suma(00+0r2+0g2+0b2)|0
	por xmm13, xmm11 ; 0|0|0|0|0|0|0|0|0|0|0|0|suma(00+0r4+0g4+0b4)|suma(00+0r3+0g3+0b3)|suma(00+0r2+0g2+0b2)|suma(00+0r1+0g1+0b1)

	; pixel suma 0
	pxor xmm11, xmm11
	movdqu xmm11, xmm10 ; 0|sum(r4)|sum(g4)|sum(b4)|sum(r3)|sum(g3)|sum(b3)|sum(r2)|sum(g2)|sum(b2)|sum(r1)|sum(g1)|sum(b1)|sum(r0)|sum(g0)|sum(b0)
	pslldq xmm11, 12 ; 0|sum(r0)|sum(g0)|sum(b0)|0|0|0|0|0|0|0|0|0|0|0|0
	pand xmm11, xmm8 ; 0|sum(r)|sum(g)|sum(b)|0|0|0|0|0|0|0|0|0|0|0|0
	pxor xmm12, xmm12
	; unpack a word 
	punpckhbw xmm11, xmm12 ; 00|0r|0g|0b|00|00|00|00
	; suma horizontal de a word: como los valores son 0r 0g 0b son todos positivos 
	; y la suma en el peor caso es 510 < 32,767
	phaddw xmm11, xmm12 ; 00+00|00+00|00+00|00+00|00+00|00+00|00+0r|0g+0b
	; otra vez: es en el peor caso 1020 < 32,767
	phaddw xmm11, xmm12 ; 00+00|00+00|00+00|00+00|00+00|00+00|00+00|00+0r+0g+0b
	; luego packear saturado.
	packuswb xmm11, xmm12 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|suma(00+0r0+0g0+0b0)
	pslldq xmm13, 1 ; 0|0|0|0|0|0|0|0|0|0|0|suma(00+0r4+0g4+0b4)|suma(00+0r3+0g3+0b3)|suma(00+0r2+0g2+0b2)|suma(00+0r1+0g1+0b1)|0
	por xmm13, xmm11 ; 0|0|0|0|0|0|0|0|0|0|0|suma(00+0r4+0g4+0b4)|suma(00+0r3+0g3+0b3)|suma(00+0r2+0g2+0b2)|suma(00+0r1+0g1+0b1)|suma(00+0r0+0g0+0b0)

	paddusb xmm14, xmm13 ; 0|0|0|0|0|0|0|0|0|0|0|suma_hasta_r10(00+0r4+0g4+0b4)|suma_hasta_r10(00+0r3+0g3+0b3)|suma_hasta_r10(00+0r2+0g2+0b2)|suma_hasta_r10(00+0r1+0g1+0b1)|suma_hasta_r10(00+0r0+0g0+0b0)

	add r13, r12
	inc r10
	cmp r10, 5
	jl .cincoEnParalelo

; xmm14  0|0|0|0|0|0|0|0|0|0|0|sumargb_i,j+4|sumargb_i,j+3|sumargb_i,j+2|sumargb_i,j+1|sumargb_i,j

; por cada pixel valido  en xmm14 procedo a calcular la formula:
; primero calculo suma(r+g+b)*Lij como un producto no signado en float (b->w->dw->pf).
; Luego multiplico por el alpha extendido a float como un producto signado. 
; Luego realizo la division por MAX como una division signada en float
; Por ultimo realizo la suma con Lij como una suma signada de floats y luego saturo hasta byte.

	pxor xmm2, xmm2
	movd xmm2, [rbp + 16] ; 0|0|0|alpha
	cvtsi2ss xmm2, xmm2 ; cast to float!
	movdqu xmm1, xmm2 ; 0|0|0|alpha
	pslldq xmm1, 1 ; 0|0|alpha|0
	por xmm1, xmm2 ; 0|0|alpha|alpha
	pslldq xmm1, 1 ; 0|alpha|alpha|0
	por xmm1, xmm2 ; 0|alpha|alpha|alpha

	pxor xmm3, xmm3
	movd xmm3, [maxValue] ; 0|0|0|max
	cvtsi2ss xmm2, xmm2 ; cast to float!
	pxor xmm2, xmm2 
	movdqu xmm2, xmm3 ; 0|0|0|max
	pslldq xmm2, 1 ; 0|0|max|0
	por xmm2, xmm3 ; 0|0|max|max
	pslldq xmm4, 1 ; 0|max|max|0
	por xmm2, xmm3 ; 0|max|max|max

    movdqu xmm9, [salvarUnPixelShifteable] ; 0|0|0|0|0|0|0|0|0|0|0|0|FF|FF|FF|0
    psrldq xmm9, 1 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|FF|FF|FF

	cmp r9, r15
	jge .mayorIgAColsToProccess ; mayor igual a colsToProccess

	pxor xmm15, xmm15
	movdqu xmm15, xmm14 ; 0|0|0|0|0|0|0|0|0|0|0|sumargb_i,j+4|sumargb_i,j+3|sumargb_i,j+2|sumargb_i,j+1|sumargb_i,j
	psrldq xmm8, 3 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|FF
	pand xmm15, xmm8 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|sumargb_i,j
	pxor xmm12, xmm12
	por xmm12, xmm15 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|sumargb_i,j
	pslldq xmm12, 1 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|0|sumargb_i,j|0
	por xmm12, xmm15 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|0|sumargb_i,j|sumargb_i,j
	pslldq xmm12, 1 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|sumargb_i,j|sumargb_i,j|0
	por xmm12, xmm15 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|sumargb_i,j|sumargb_i,j|sumargb_i,j
    pxor xmm15, xmm15
	punpcklbw xmm12, xmm15 ; 0|0|0|0|0|sumargb_i,j|sumargb_i,j|sumargb_i,j
	punpcklwd xmm12, xmm15 ; 0|sumargb_i,j|sumargb_i,j|sumargb_i,j
	cvtdq2ps xmm12, xmm12 ; cast to float!
	pxor xmm15, xmm15
	movd xmm15, [rdi + r8*4] ; 0|0|0|0|0|0|0|0|0|0|0|0|aj|rj|gj|bj <- get pixel ij
	pxor xmm0, xmm0
	movdqu xmm0, xmm15 ; 0|0|0|0|0|0|0|0|0|0|0|0|aj|rj|gj|bj
	pand xmm0, xmm9 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|rj|gj|bj
    pxor xmm3, xmm3	
    punpcklbw xmm0, xmm3 ; 0|0|0|0|0|rj|gj|bj
	punpcklwd xmm0, xmm0 ; 0|rj|gj|bj
	cvtdq2ps xmm0, xmm0 ; cast to float!
	mulps xmm12, xmm0 ; 0|sumargb_i,j*rj|sumargb_i,j*gj|sumargb_i,j*bj
	mulps xmm12, xmm1 ; 0|alpha*sumargb_i,j*rj|alpha*sumargb_i,j*gj|alpha*sumargb_i,j*bj <- puede cambiar el signo segun alpha.
	divps xmm12, xmm2 ; 0|(alpha*sumargb_i,j*rj)/max|(alpha*sumargb_i,j*gj)/max|(alpha*sumargb_i,j*bj)/max
	addps xmm12, xmm0 ; 0|rj+(alpha*sumargb_i,j*rj)/gj+max|(alpha*sumargb_i,j*gj)/bj+max|(alpha*sumargb_i,j*bj)/max
	
	/*Converts four or eight packed single-precision floating-point values in the source operand to four or eight signed
	doubleword integers in the destination operand.
	When a conversion is inexact, a truncated (round toward zero) value is returned. If a converted result is larger than
	the maximum signed doubleword integer, the floating-point invalid exception is raised, and if this exception is
	masked, the indefinite integer value (80000000H) is returned.*/
	
	cvttps2dq xmm12, xmm12 ; cast to dw signed 
	pxor xmm3, xmm3
	packusdw xmm12, xmm3 ; 0|0|0|0|0|rj+(alpha*sumargb_i,j*rj)/gj+max|(alpha*sumargb_i,j*gj)/bj+max|(alpha*sumargb_i,j*bj)/max
	packuswb xmm12, xmm3 ; 0|0|0|0|0|0|0|0|0|0|0|0|0|rj+(alpha*sumargb_i,j*rj)/gj+max|(alpha*sumargb_i,j*gj)/bj+max|(alpha*sumargb_i,j*bj)/max <- tengo los canales calculados saturados a byte.

	inc r9
	inc r8
	cmp r9, r15
	jge .mayorIgAColsToProccess ; mayor igual a colsToProccess
	; procesar sumargb_i,j+1
	inc r9
	inc r8
	cmp r9, r15
	jge .mayorIgAColsToProccess ; mayor igual a colsToProccess
	; procesar sumargb_i,j+2
	inc r9
	inc r8
	cmp r9, r15
	jge .mayorIgAColsToProccess ; mayor igual a colsToProccess
	; procesar sumargb_i,j+3
	inc r9
	inc r8
	cmp r9, r15
	jge .mayorIgAColsToProccess ; mayor igual a colsToProccess
	; procesar sumargb_i,j+4
	inc r9
	inc r8
	cmp r9, r15
	jge .mayorIgAColsToProccess ; mayor igual a colsToProccess
	jmp .seguir

.menorAColDos:
; Tengo que devolver r9

.mayorIgAColsToProccess:
; Tengo que devolver las columnas:
; r9, r9+1 && edx==1?r9+2 <- incrementarlo
	xor r9, r9 ; reinicio contador columna actual.

.seguir:
	cmp r8, rcx
	jne .ciclo

.terminar:

.salir:
	add rsp, 8
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret
