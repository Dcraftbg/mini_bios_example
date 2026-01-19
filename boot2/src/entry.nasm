[BITS 32]
extern main
section .entry
global _start
_start:
    mov ax, 0x10
    mov ds, ax
    mov ss, ax
    mov ax, ds
    mov esp, 0x90000

    call main
    ; mov byte [0xB8000], 'P'
    ; mov byte [0xB8001], 0x1B
hang:
    jmp hang

