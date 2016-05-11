# ** por compatibilidad se omiten tildes **
# ==============================================================================
# TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
# ==============================================================================

MCOPY=mcopy

KERNEL_SRC=kernel.asm
KERNEL_OBJ=kernel.o
KERNEL_BIN=kernel.bin

DEPEND = Makefile \
	kernel.asm isr.asm \
	imprimir.mac \
	defines.h \
	gdt.c gdt.h pic.c pic.h idt.c idt.h isr.h tss.c tss.h mmu.c mmu.h \
	sched.c sched.h screen.c screen.h \
	game.c game.h syscall.h

OBJ=$(KERNEL_OBJ) gdt.o pic.o idt.o isr.o mmu.o sched.o tss.o screen.o game.o
DISK_IMG=diskette.img
DISK_IMG_BZ=diskette.img.bz2

CFLAGS=-m32 -g -ggdb -Wall -Werror -O0 \
  -fno-zero-initialized-in-bss -fno-stack-protector -ffreestanding


TASKIDLE=idle.tsk
TASKA=taskA.ctsk
TASKB=taskB.ctsk
TASKH=taskH.ctsk

TASKS=tareas.tsk

TASKSBINS=$(TASKIDLE) $(TASKA) $(TASKB) $(TASKH)

CODESIZE=60928    # = 65536 - 0x1200 = 64KB - 0x1200
TASKSSIZE=16384   # = 1 * (4096) + 3 * (4096) = idle + tareas
KERNELSIZE=77312  # = CODESIZE + TASKSSIZE

TASKSTARTADDR=0x40000000

CC=gcc
NASM=nasm
NASMFLAGS=-felf32
OBJCOPY=objcopy
NM=nm
LD=ld
LDTASKFLAGS=-s -static -m elf_i386 --oformat binary -b elf32-i386 -e task -Ttext $(TASKSTARTADDR)
LDFLAGS=-static -m elf_i386 -b elf32-i386 -e start -Ttext 0x1200

QUIET = @

.PHONY=clean all image tasks defines.h

all:  clean tasks image 

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $^

%.o: %.asm
	$(NASM) $(NASMFLAGS) -o $@ $^

kernel.bin: $(OBJ) $(TASKS)
	@echo 'Linkeando kernel...'
	$(LD) $(LDFLAGS) -o $@.tmp $(OBJ)
	$(NM) $@.tmp | grep -v " U " | awk '{print "0x" $$1 " " $$3}' > kernel.sym
	$(OBJCOPY) -S -O binary $@.tmp $@
	rm $@.tmp
	@echo ''

	@echo 'Generando imagen del kernel...'
	mv kernel.bin kernel.bin.tmp
	dd if=/dev/zero of=kernel.bin bs=1 count=$(KERNELSIZE) conv=notrunc status=noxfer > /dev/null 2>&1
	dd if=kernel.bin.tmp of=kernel.bin bs=1 count=$(CODESIZE) conv=notrunc status=noxfer > /dev/null 2>&1
	dd if=$(TASKS) of=kernel.bin bs=1 count=$(TASKSSIZE) seek=$(CODESIZE) conv=notrunc status=noxfer > /dev/null 2>&1
	rm kernel.bin.tmp
	@echo ''

image: kernel.bin $(DEPEND) $(DISK_IMG)
	@echo 'Copiando el $(KERNEL_BIN) a la imagen de diskette'
	$(MCOPY) -o -i $(DISK_IMG) $(KERNEL_BIN) ::/
	@echo ''

$(DISK_IMG): $(DISK_IMG_BZ)
	bzip2 -dk $(DISK_IMG_BZ)

idle.tsk: idle.asm
	@echo 'Compilando tarea...'
	$(NASM) -fbin -o $@ $^
	@echo ''
	@echo 'Generando imagen de la tarea idle...'
	mv idle.tsk idle.tsk.tmp
	dd if=/dev/zero bs=1 count=4K of=$@ status=noxfer > /dev/null 2>&1
	dd if=$@.tmp bs=1 count=4K seek=0 conv=notrunc of=$@ status=noxfer > /dev/null 2>&1
	rm $@.tmp
	@echo ''

taskA.tsko: tareaA.c
	$(CC) $(CFLAGS) -c -o $@ $^
taskB.tsko: tareaB.c
	$(CC) $(CFLAGS) -c -o $@ $^
taskH.tsko: tareaH.c
	$(CC) $(CFLAGS) -c -o $@ $^

%.ctsk: %.tsko
	@echo 'Linkeando tarea...'
	$(LD) $(LDTASKFLAGS) -o $@.tmp $^
	@echo ''
	mv $@.tmp $@

tasks: $(TASKSBINS)
	@echo 'Generando imagen de las tareas...'
	$(QUIET) dd if=/dev/zero bs=1 count=$(TASKSSIZE) of=$(TASKS)  status=noxfer > /dev/null 2>&1
	$(QUIET) dd if=$(TASKIDLE) bs=1 count=4K of=$(TASKS) seek=0K  status=noxfer > /dev/null 2>&1
	$(QUIET) dd if=$(TASKA)    bs=1 count=4K of=$(TASKS) seek=4K  status=noxfer > /dev/null 2>&1
	$(QUIET) dd if=$(TASKB)    bs=1 count=4K of=$(TASKS) seek=8K  status=noxfer > /dev/null 2>&1
	$(QUIET) dd if=$(TASKH)    bs=1 count=4K of=$(TASKS) seek=12K status=noxfer > /dev/null 2>&1
	@echo ''

clean:
	@echo 'Limpiando todo...'
	rm -f *.o
	rm -f *.bin
	rm -f *.tmp
	rm -f *.ctsko
	rm -f kernel.sym
	rm -f *.ctsk
	rm -f *.tsko
	rm -f *.tsk
	rm -f $(DISK_IMG)
	rm -rf *~
	@echo ''
	
