jmp kernel_start

kernel_start:
    call clr_screen
    mov ax, welcome_msg
    call printf

.shell_loop:
    mov ax, prompt_char
    call putc
    mov di, linebuffer      ; Set DI to start of line buffer
    mov si, di              ; Track current buffer content

.key_loop:
    call get_keystroke      ; Get a keystroke and store it in SI
    mov ax, si              ; Move keystroke from SI to AX

    cmp ax, left_arrow
    je .move_cursor_left
    cmp ax, right_arrow
    je .move_cursor_right
    cmp ax, newline_char
    je .if_enter_key
    cmp ax, backspace_char
    je .if_backspace_key
    cmp di, linebuffer_end  ; Check if buffer end is reached
    je .key_loop            ; Stay in loop if end is reached

    call putc
    stosb                   ; Store char in buffer and increment DI
    jmp .key_loop           ; Jump back to start of key loop

.if_enter_key:
    mov ax, crlf
    call printf

    mov ax, linebuffer

    ; call interpreter

    mov dx, 0               ; Prepare DX:AX for memset call
    mov cx, linebuffer_len  ; Set length for memset
    call memset             ; Clear line buffer

    jmp .shell_loop         ; Jump back to shell loop

.if_backspace_key:
    cmp di, linebuffer      ; Check if at start of buffer
    je .key_loop            ; If so, jump back to key loop
    call putc               ; Print backspace char
    mov al, ' '
    call putc               ; Print space to erase last char
    mov al, backspace_char
    call putc               ; Move cursor back
    dec di                  ; Decrement DI to erase char
    mov byte [di], 0        ; Nullify erased char

    jmp .key_loop           ; Jump back to key loop

.move_cursor_left:
    cmp di, linebuffer      ; Check if at start of buffer
    je .key_loop            ; If so, do nothing
    mov al, backspace_char
    call putc               ; Move cursor back
    dec di                  ; Decrement DI to move cursor left in the buffer
    jmp .key_loop           ; Return to the main key loop

.move_cursor_right:
    cmp di, si              ; Compare current position with end of content
    jge .key_loop           ; If DI >= SI, do nothing
    mov al, [di]            ; Load the character at the new cursor position into AL
    inc di                  ; Otherwise, move DI one position to the right
    call putc               ; Output the character
    jmp .key_loop

welcome_msg db "Welcome to StoneageOS!", 10, 13, 0
crlf db 13, 10, 0
prompt_char equ '>'
newline_char equ 13
backspace_char equ 8
right_arrow equ 0x4800
left_arrow equ 0x4B00
up_arrow equ 0x4D00
down_arrow equ 0x5000
db 0xab, 0xcd
linebuffer_len equ 78
linebuffer times linebuffer_len db 0
linebuffer_end: db 0

%include "mem_utils.S"
%include "bios.S"
%include "print_utils.S"