jmp kernel_start

kernel_start:
    call clr_screen
    mov ax, welcome_msg
    call printf

.shell_loop:
    mov ax, prompt_char
    call putc
    mov di, linebuffer      ; Set DI to start of line buffer

.key_loop:
    call get_keystroke      ; Get a keystroke and store it in SI

    mov ax, si              ; Move keystroke from SI to AX
    cmp ax, newline_char    ; Check if it's a newline char
    je .if_enter_key        ; Jump if it's an enter key press
    cmp ax, backspace_char  ; Check if it's a backspace char
    je .if_backspace_key    ; Jump if it's a backspace key press
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

welcome_msg db "Welcome to StoneageOS!", 10, 13, 0
crlf db 13, 10, 0
prompt_char equ '>'
newline_char equ 13
backspace_char equ 8
db 0xab, 0xcd
linebuffer_len equ 78
linebuffer times linebuffer_len db 0
linebuffer_end: db 0

%include "mem_utils.S"
%include "bios.S"
%include "print_utils.S"