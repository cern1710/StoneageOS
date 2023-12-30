; Register-preserving print functions

; Prints a character in AL using BIOS interrupt
putc:
    push ax
    push bx
    mov ah, 0x0E        ; BIOS teletype output function
    mov bh, 0           ; Display page number
    int 0x10            ; BIOS video interrupt
    pop bx
    pop ax
    ret

; Prints a null-terminated string pointed to by AX
printf:
    push ax
    push bx
    mov si, ax          ; SI points to the string
    mov ah, 0x0E        ; BIOS teletype output function
    mov bh, 0           ; Display page number
.loop:
    lodsb               ; Load byte at SI into AL and increment SI
    or al, al           ; Check if AL is zero (end of string)
    jz .end             ; If zero, end of string
    int 0x10            ; BIOS video interrupt
    jmp .loop
.end:
    pop bx
    pop ax
    ret