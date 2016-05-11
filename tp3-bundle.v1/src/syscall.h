/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================
  definicion de la tabla de descriptores globales
*/

#ifndef __SYSCALL_H__
#define __SYSCALL_H__

#define LS_INLINE static __inline __attribute__((always_inline))

/*
 * Syscalls
 */

LS_INLINE unsigned int syscall_soy(int v) {
    int ret;

    //asm(".intel_syntax noprefix");
    
    __asm __volatile(
        "mov $0xA6A, %%eax \n"
        "mov %0, %%ebx \n"
        "int $0x66     \n"
        : /* no output*/
        : "m" (v)
        : "eax"
    );

    __asm __volatile("mov %%eax, %0" : "=r" (ret));

    return ret;
}

LS_INLINE unsigned int syscall_mapear(int x, int y) {
    int ret;

    //asm(".intel_syntax noprefix");
    
    __asm __volatile(
        "mov $0xFF3, %%eax \n"
        "mov %0, %%ebx \n"
        "mov %1, %%ecx \n"
        "int $0x66     \n"
        : /* no output*/
        : "m" (x), "m" (y)
        : "eax"
    );

    __asm __volatile("mov %%eax, %0" : "=r" (ret));

    return ret;
}

LS_INLINE unsigned int syscall_donde(int* a) {
    int ret;

    //asm(".intel_syntax noprefix");
    
    __asm __volatile(
        "mov $0x124, %%eax \n"
        "mov %0, %%ebx \n"
        "int $0x66     \n"
        : /* no output*/
        : "m" (a)
        : "eax"
    );

    __asm __volatile("mov %%eax, %0" : "=r" (ret));

    return ret;
}

#endif  /* !__SYSCALL_H__ */
