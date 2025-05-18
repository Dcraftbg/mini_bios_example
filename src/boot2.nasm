[BITS 16]
org 0x7C00+512
boot_2_sectors_count: dw ((boot_2_end-boot_2_sectors_count) + 511)/512

_start:
    mov si, stage_2_msg
    call puts
.loop:
    hlt
    jmp .loop



puts:
    ; save registers we will modify
    push si
    push bx
    push ax
.loop:
    lodsb               ; loads next character in al
    or al, al           ; verify if next character is null?
    jz .done
    mov ah, 0x0E        ; call bios interrupt
    mov bh, 0           ; set page number to 0
    int 0x10
    jmp .loop
.done:
    pop ax
    pop bx
    pop si    
    ret
print_digit:
    push ax
    mov ah, 0x0E
    mov al, [si + hex_digits]
    int 0x10
    pop ax
    ret
print_byte:
    push si
    push ax
    mov ax, si
    shr si, 4
    and si, 0xF
    call print_digit
    mov si, ax
    and si, 0xF
    call print_digit
    pop ax
    pop si
    ret
print_word:
    push si
    shr si, 8
    call print_byte
    pop si
    jmp print_byte
    
; Data
stage_2_msg: db "Hello from Stage 2 :)", 0
hex_digits: db "0123456789ABCDEF"
boot_2_end:
