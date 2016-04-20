
global ldr_asm

section .data

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
	mov r10d, [rsp-8] ; alpha
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
	xor r8, r8 ; posicion actual
	xor r9, r9 ; j = 0

; devolver las primeras dos filas tal cual estan. 
; devolver las ultimas dos filas tal cual estan. 

	mov r8, r15
	shl r8, 1 ; i = 2 - j = 0

.ciclo: ; while(ecx > 0)
; if(j < colsToProccess)
	cmp r9, r15
	jge .sinFormula ; mayor a colsToProccess
	; estoy en rango.
	mov r13, r15
	add r13, 2
	add r13, edx ; columnas totales.
	mov r14, r8 ; i
	sub r14, r13
	sub r14, r13 ; i-2
	xor r10, r10 ; cuento hasta 5
.cincoEnParalelo: ; Puedo procesar 5 pixeles en paralelo - los pixeles que estan en columnas mayores a colsToProccess no se tendran en cuenta.
	movdqu xmm0, [rdi + r14*4] ; Li0|Li1|Li2|Li3
	movdqu xmm1, [rdi + r14*4 + 1] ; Li1|Li2|Li3|Li4
	movdqu xmm2, [rdi + r14*4 + 2] ; Li2|Li3|Li4|Li5
	movdqu xmm3, [rdi + r14*4 + 3] ; Li3|Li4|Li5|Li6
	movdqu xmm4, [rdi + r14*4 + 4] ; Li4|Li5|Li6|Li7
	; traer una columna mas y sumar y acumular en xmm5
	add r14, r13
	add r10, 1
	cmp r10, 5
	jl .cincoEnParalelo

.sinFormula:
; Tengo que devolver las columnas:
; colsToProccess, colsToProccess+1 && edx==1?colsToProccess+2

	loop .ciclo


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
