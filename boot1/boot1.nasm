[BITS 16]
org 0x7C00

struc Boot2Header
    .sector_count resw 1
    .boot_disk resb 1
    .boot_sectors_per_track resw 1
    .boot_number_of_heads resw 1
    .entry resb 0
endstruc
mov [boot_disk], dl
mov ah, 8
int 0x13
and cl, 0x3f
mov [boot_sectors_per_track], cl
mov [boot_number_of_heads], dh

mov bx, boot_2
mov al, 1
call boot_load_sector
jc error
inc al
add bx, 512

mov dx, word [boot_2+Boot2Header.sector_count]
load_loop:
    cmp ax, dx
    jge jump_to_boot2
    call boot_load_sector
    jc error
    inc al
    add bx, 512
    jmp load_loop
jump_to_boot2:
    mov al, byte [boot_disk]
    mov byte [boot_2+Boot2Header.boot_disk], al
    mov ax, word [boot_sectors_per_track]
    mov word [boot_2+Boot2Header.boot_sectors_per_track], ax
    mov ax, word [boot_number_of_heads]
    mov word [boot_2+Boot2Header.boot_number_of_heads], ax

    ; fast A20 gate
    in al, 0x92
    or al, 2
    out 0x92, al

    ; jump to protected mode
    cli
    xor ax, ax
    mov ds, ax
    lgdt [gdtr]
    mov eax, cr0
    or al, 1
    mov cr0, eax
    jmp 0x08:boot_2+Boot2Header.entry

ACC_PRESENT    equ 1 << 7
ACC_DPL_SHIFT  equ 5
ACC_DPL_KERNEL equ (0x0 << ACC_DPL_SHIFT)
ACC_SYSTEM     equ 1 << 4
ACC_EXEC       equ 1 << 3
ACC_DC         equ 1 << 2
ACC_RW         equ 1 << 1
ACC_DIRTY      equ 1 << 0

FLAG_GRANULARITY    equ 0x8
FLAG_PROTECTED_MODE equ 0x4

%define GDT_DESC_BASE0_LIMIT_FFFFF(access, flags) \
    (0x000F00000000FFFF | ((access) << 40) | ((flags) << 52))
gdt:
    dq 0
    ;  0xbbflaabbbbbbllll
    dq GDT_DESC_BASE0_LIMIT_FFFFF(ACC_DPL_KERNEL | ACC_PRESENT | ACC_SYSTEM | ACC_EXEC | ACC_RW, FLAG_PROTECTED_MODE | FLAG_GRANULARITY)
    dq GDT_DESC_BASE0_LIMIT_FFFFF(ACC_DPL_KERNEL | ACC_PRESENT | ACC_SYSTEM | ACC_RW           , FLAG_PROTECTED_MODE | FLAG_GRANULARITY)
gdt_end:

struc TableDescriptor
    .size resw 1
    .data resd 1
endstruc
gdtr: istruc TableDescriptor
    .size: dw (gdt_end-gdt)
    .data: dd gdt
iend
    ; xor ax, ax
    ; jmp boot_2+Boot2Header.entry
; AL    - sector (LBA)
; ES:BX - buffer
boot_load_sector:
    push bx
    push ax
    xor dx, dx
    mov cx, [boot_sectors_per_track]
    div cx
    inc dx
    mov [sector], dx

    xor dx, dx
    mov cx, [boot_number_of_heads]
    mov [head], dl
    mov [cylinder], al

    ; Perform read
    mov ah, 2
    mov al, 1 ; Hardcoded at 1 sector
    mov ch, [cylinder]
    mov cl, ch
    shr cl, 2
    and cl, 0xC0
    or cl, [sector]
    mov dh, [head]
    mov dl, [boot_disk]
    int 0x13
    pop bx
    mov al, bl
    pop bx
    ret

error:
    mov si, error_msg
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

; Data
error_msg: db "Disk Error", 0
; Uninitialised (Potentially move after this point?)
boot_disk: db 0
boot_sectors_per_track: dw 0
boot_number_of_heads: dw 0

sector: db 0
head: db 0
cylinder: db 0

; End of Uninitialised data
times 510-($-$$) db 0
dw 0xAA55
boot_2:
