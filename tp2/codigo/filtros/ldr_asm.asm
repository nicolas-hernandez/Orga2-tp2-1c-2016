global ldr_asm

section .data
DEFAULT REL

%define MAX 4876875
%define WHITE 255
%define BLACK 0

; En memoria: BGRA
; En registros: ARGB

juntarCanalesAlpha: DB 0x04, 0x05, 0x06, 0x00, 0x07, 0x08, 0x09, 0x01, 0x0A, 0x0B, 0x0C, 0x02, 0x0D, 0x0E, 0x0F, 0x03 
limpiarCanalesAlpha: DB 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
limpiarCanalAlphaScalar: DB 0x00, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

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
	xor r10, r10
	mov r10d, [rsp+16] ; alpha
	push rbx ; alpha
	push r12 ;
	push r13 ;
	push r14 ;
	push r15 ;
	sub rsp, 8 ; alineado
	xor rbx, rbx
	mov ebx, r10d ; alpha

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
    movdqu xmm8, [limpiarCanalAlphaScalar]

.ciclo: ; while(r8 < rcx) == (actual < total) 
; if(j < colsToProccess)
	cmp r9, r15
	jge .sinFormula ; mayor igual a colsToProccess
	; estoy en rango.
	mov r12, r15
	add r12, 2
	add r12, edx ; columnas totales.
	mov r14, r8 ; posicion actual
	sub r14, r12
	sub r14, r12 ; posicion actual - dos filas
	xor r10, r10 ; cuento hasta 5
.cincoEnParalelo: ; Puedo procesar 5 pixeles en paralelo - los pixeles que estan en columnas mayores a colsToProccess no se tendran en cuenta.
    ; me corro -2 posiciones
    mov r13, r14
    sub r13, 2
    
    ;              32  16   8   4   0
    ; Li7|Li6|Li5|Li4|Li3|Li2|Li1|Li0

	movdqu xmm0, [rdi + r13*4] ; Li3|Li2|Li1|Li0
	pshufb xmm0, xmm6 ; r|g|b|r|g|b|r|g|b|r|g|b|a|a|a|a
	pand xmm0, xmm7 ; r|g|b|r|g|b|r|g|b|r|g|b|0|0|0|0
	
	movdqu xmm1, [rdi + r13*4 + 4] ; Li4|Li3|Li2|Li1
    pshufb xmm1, xmm6 ; r|g|b|r|g|b|r|g|b|r|g|b|a|a|a|a
	pand xmm1, xmm7 ; r|g|b|r|g|b|r|g|b|r|g|b|0|0|0|0
	
	pxor xmm9, xmm9
	movdqu xmm9, xmm1
	psrldq xmm9, 3 ; 0|0|0|r|g|b|r|g|b|r|g|b|r|g|b|0
	pand xmm9, xmm8 ; 0|0|0|0|0|0|0|0|0|0|0|0|r|g|b|0
    por xmm0, xmm9 ; r|g|b|r|g|b|r|g|b|r|g|b|r|g|b|0
	
	movdqu xmm2, [rdi + r13*4 + 8] ; Li5|Li4|Li3|Li2
	pshufb xmm2, xmm6 ; r|g|b|r|g|b|r|g|b|r|g|b|r|a|a|a
	pand xmm2, xmm7 ; r|g|b|r|g|b|r|g|b|r|g|b|r|0|0|0

	pxor xmm9, xmm9
	movdqu xmm9, xmm2
	psrldq xmm9, 3 ; 0|0|0|r|g|b|r|g|b|r|g|b|r|g|b|0
	pand xmm9, xmm8 ; 0|0|0|0|0|0|0|0|0|0|0|0|r|g|b|0
    por xmm1, xmm9 ; r|g|b|r|g|b|r|g|b|r|g|b|r|g|b|0
	
	movdqu xmm3, [rdi + r13*4 + 16] ; Li6|Li5|Li4|Li3
	pshufb xmm3, xmm6 ; r|g|b|r|g|b|r|g|b|r|g|b|r|a|a|a
	pand xmm3, xmm7 ; r|g|b|r|g|b|r|g|b|r|g|b|r|0|0|0

	pxor xmm9, xmm9
	movdqu xmm9, xmm3
	psrldq xmm9, 3 ; 0|0|0|r|g|b|r|g|b|r|g|b|r|g|b|0
	pand xmm9, xmm8 ; 0|0|0|0|0|0|0|0|0|0|0|0|r|g|b|0
    por xmm2, xmm9 ; r|g|b|r|g|b|r|g|b|r|g|b|r|g|b|0
	
	movdqu xmm4, [rdi + r13*4 + 32] ; Li7|Li6|Li5|Li4
	pshufb xmm4, xmm6 ; r|g|b|r|g|b|r|g|b|r|g|b|r|a|a|a
	pand xmm4, xmm7 ; r|g|b|r|g|b|r|g|b|r|g|b|r|0|0|0
	
    pxor xmm9, xmm9
	movdqu xmm9, xmm4
	psrldq xmm9, 3 ; 0|0|0|r|g|b|r|g|b|r|g|b|r|g|b|0
	pand xmm9, xmm8 ; 0|0|0|0|0|0|0|0|0|0|0|0|r|g|b|0
    por xmm3, xmm9 ; r|g|b|r|g|b|r|g|b|r|g|b|r|g|b|0
    
    pxor xmm9, xmm9
    movd xmm9, [rdi + r13*4 + 64] ; 0|0|0|0|0|0|0|0|0|0|0|0|r|g|b|a
	pand xmm9, xmm8 ; 0|0|0|0|0|0|0|0|0|0|0|0|r|g|b|0
    por xmm4, xmm9 ; r|g|b|r|g|b|r|g|b|r|g|b|r|g|b|0
    
    ; realizar suma vertical de bytes saturada, luego sumar hacia la izquierda?? y acumular en xmm10
	
	add r13, r12
	inc r10
	cmp r10, 5
	jl .cincoEnParalelo

.sinFormula:
; Tengo que devolver las columnas:
; colsToProccess, colsToProccess+1 && edx==1?colsToProccess+2

    inc r8
	cmp r8, rcx
	jne .ciclo


.terminar:

.salir:
	add rsp, 8
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret
