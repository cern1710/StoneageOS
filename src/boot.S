; Start memory at 0x7c00 for bootloading of PC BIOS
[ORG 7c00h]

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

    ; In real hardware the BIOS puts the address of the booting drive on the dl register
    ; so I am writing that addres into memory at [bootdrv]
    mov [bootdrv], dl

    mov ax, 07c0h
    shr ax, 4               ; Set offset with shr instead of adding 288
    mov ss, ax              ; ss = stack space
    mov sp, 4096            ; sp = stack pointer

    mov ax, 07c0h           ; ds = data segment
    shr ax, 4
    mov ds, ax
