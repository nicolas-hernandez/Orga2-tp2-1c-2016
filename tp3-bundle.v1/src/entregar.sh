#!/usr/bin/env bash

entrega="entrega.zip" #cambia el nombre del archivo comprimido


zip $entrega     \
	kernel.asm   \
	Makefile     \
	bochsdbg     \
	bochsrc      \
	imprimir.mac \
	a20.asm      \
	defines.h    \
	colors.h     \
	i386.h       \
	syscall.h    \
	gdt.h        \
	gdt.c        \
	isr.h        \
	isr.asm      \
	mmu.h        \
	mmu.c        \
	sched.h      \
	sched.c      \
	tss.h        \
	tss.c        \
	idt.h        \
	idt.c        \
	game.h       \
	game.c       \
	pic.h        \
	pic.c        \
	screen.h     \
	screen.c     \
	tareaA.c     \
	tareaB.c     \
	tareaH.c     \
	idle.asm    

