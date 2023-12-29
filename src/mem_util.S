; Params:
;    ax: Memory block addr
;    dl: Value to set
;    cx: Memory block len
memset:
    pusha               ; Save current general-purpose reg
    mov di, ax          ; Move addr into DI
    mov al, dl          ; Move value into AL
    mov ah, al          ; Set AH to same value for word size operation
    mov bx, cx          ; Copy CX into BX for test later
    shr cx, 1           ; CX / 2 for word size operation
    rep stosw           ; Store AX into memory DI points to
    test bx, 1          ; Check if original len was odd
    jz .end             ; Return if original len is even
    stosb               ; Store remaining byte

.end:
    popa                ; Restore all general-purpose reg
    ret


; Params:
;    si: Src addr
;    di: Dest addr
;    cx: #bytes to move
memmove:
    pusha
    cmp si, di          ; Compare src and dest addr
    ja .forward         ; If src > dest, move forward
    std                 ; Set direction flag for backward movement
    add si, cx          ; Adjust src index to end of block
    dec si              ; Decrement src index (point to last byte of src)
    add di, cx          ; Adjust dest index to end of block
    dec di              ; Decr dest index (point to last byte of dest)
    rep movsb           ; Move bytes from src to dest backwards
    cld                 ; Clear direction flag (reset to default forward movement)
    jmp .end            ; Jump to end to avoid forward movement code

.forward:
    rep movsb           ; Move bytes from src to dest forward

.end:
    popa


; Params:
;    si: First memory block addr
;    di: Second memory block addr
;    cx: #bytes to compare
; Returns:
;    Zero flag set if blocks are equal
memcmp:
    pusha
    repe cmpsb          ; Repeat comparing bytes until they differ or CX = 0
    popa
    ret
