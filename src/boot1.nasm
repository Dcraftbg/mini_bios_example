[BITS 16]
org 0x7C00

mov [boot_disk], dl
mov ah, 8
int 0x13
and cl, 0x3f
mov [boot_sectors_per_track], cl
mov [boot_number_of_heads], dh

struc Boot2Header
    .sector_count resw 1
    .entry resb 0
endstruc
mov bx, boot_2
mov al, 1
call boot_load_sector
jc error
inc al
add bx, 512

mov dx, word [boot_2+Boot2Header.sector_count]
load_loop:
    cmp ax, dx
    jge boot_2+Boot2Header.entry ; al >= BOOT_2_SECTORS
    call boot_load_sector
    jc error
    inc al
    add bx, 512
    jmp load_loop

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
