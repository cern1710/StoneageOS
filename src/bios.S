clr_screen:
    pusha
    mov ax, 0           ; Position cursor at top-left
    call move_cursor
    mov ah, 0x06        ; Scroll up function
    mov al, 0           ; Scroll entire window
    mov bh, 0x02        ; Attribute (Green text, black background)
    mov cx, 0           ; Top-left corner (row, col = 0)
    mov dh, 24          ; Bottom-right row
    mov dl, 79          ; Bottom-right column
    int 0x10            ; BIOS video interrupt
    popa
    ret

move_cursor:
    pusha
    mov dx, ax          ; Move row and column to DX
    mov bh, 0           ; Display page number
    mov ah, 0x02        ; BIOS set cursor position function
    int 0x10            ; BIOS video interrupt
    popa
    ret

get_keystroke:
    push ax
    mov ah, 0           ; BIOS keyboard function (get keystroke)
    int 0x16            ; BIOS keyboard interrupt
    cmp al, 0xE0        ; Check for special key indicator
    je .done
    cmp al, 0x00        ; Check for special key indicator
    je .done
    xor ah, ah          ; Clear AH to ignore scan code
    jmp .done
.done:
    mov si, ax         ; Move keystroke to SI
    pop ax
    ret