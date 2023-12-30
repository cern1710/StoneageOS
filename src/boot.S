; Start memory at 0x7c00 for bootloading of PC BIOS
[ORG 0x7c00]

; Source: https://github.com/pablojimenezmateo/curriculum-bootloader
; Changes have been made for this kernel

bits 16

boot:
    ; This is a BPB, so that the BIOS does not overwrite our code
    ; https://stackoverflow.com/questions/47277702/custom-bootloader-booted-via-usb-drive-produces-incorrect-output-on-some-compute
    jmp start
    TIMES 3-($-$$) DB 0x90   ; Support 2 or 3 byte encoded JMPs before BPB.

    ; Dos 4.0 EBPB 1.44MB floppy
    OEMname:           db    "mkfs.fat"  ; mkfs.fat is what OEMname mkdosfs uses
    bytesPerSector:    dw    512
    sectPerCluster:    db    1
    reservedSectors:   dw    1
    numFAT:            db    2
    numRootDirEntries: dw    224
    numSectors:        dw    2880
    mediaType:         db    0xf0
    numFATsectors:     dw    9
    sectorsPerTrack:   dw    18
    numHeads:          dw    2
    numHiddenSectors:  dd    0
    numSectorsHuge:    dd    0
    driveNum:          db    0
    reserved:          db    0
    signature:         db    0x29
    volumeID:          dd    0x2d7e5a1a
    volumeLabel:       db    "NO NAME    "
    fileSysType:       db    "FAT12   "

    ; This is used to offset all memory addresses by 8 bytes, or the size of the PDF magic numbers
    dw 0xffff, 0xffff, 0xffff, 0xffff

start:
    cli                 ; Disable interrupts
    mov [bootdrv], dl   ; Store boot drive
    xor ax, ax          ; Clear AX register
    mov ds, ax          ; Init data segment -> 0
    mov es, ax          ; Init extra segment -> 0
    mov ss, ax          ; Init stack segment -> 0
    mov sp, 0x7c00      ; Set stack ptr to 0x7c00
    sti                 ; Enable interrupts

    mov si, 2           ; Initialize SI reg (retry counter)

.top:
    mov ah, 0x02        ; Reading from disk function
    mov al, 0x04        ; Read 4 sectors
    mov ch, 0x00        ; Cylinder number
    mov cl, 0x02        ; Start from the second sector
    xor dh, dh          ; Head number
    mov dl, [bootdrv]   ; Drive number

    mov bx, 0x1000      ; Buffer addr offset for kernel loading
    mov es, bx          ; Buffer address for kernel
    xor bx, bx          ; Clear BX; use as offset
    int 0x13            ; Call interrupt on disk
    jnc .load_success   ; Carry flag not set; success
    dec si              ; Decrement retry counter
    jz .load_error      ; If number of retries have been exhausted
    xor ah, ah          ; Clear AH before retrying
    int 0x13            ; Retry disk op
    jmp .top

.load_success:
    mov si, success_msg
    call boot_print
    mov ax, 0x1000      ; Set AX to segment addr for kernel
    mov ds, ax
    mov es, ax
    jmp 0x1000:0x0000

.load_error:
    mov si, error_msg
    call boot_print
    jmp $

; BIOS Routine to print a string at DS:SI
; Only used in the bootloader!
boot_print:
    pusha               ; Push all general-purpose registers
.loop:
    lodsb               ; Load byte at DS:SI into AL and increment SI
    test al, al         ; Test if AL = zero (end of string)
    jz .done            ; Exit if we've reached end of string
    mov ah, 0x0E        ; BIOS teletype function
    mov bh, 0x00        ; Page number
    int 0x10            ; Call BIOS interrupt
    jmp .loop
.done:
    popa                ; Restore all general-purpose registers
    ret

success_msg db "Load successful!", 13, 10, 0
error_msg db "Error loading!", 13, 10, 0

bootdrv db 0            ; Boot drive number
times 510-($-$$) db 0   ; Pad remaining boot sector with 0s
dw 0xaa55               ; Boot sector signature