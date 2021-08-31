CHGMOD:  equ $005F  ; BIOS change screen mode routine
WRTVRM:  equ $004D  ; BIOS routine to write into vram
RDVRM:   equ $004A  ; BIOS routine to read from vram
FILVRM:  equ $0056  ; BIOS routine to fill vram
GRPPRT:  equ $008D  ; BIOS routine for print characters on screen
CHGET:   equ $009F  ; BIOS routine for getting key press

GRPCOL:  equ $F3C9  ; address in vram for color table
GRPCGP:  equ $F3CB  ; address in vram for bitmap data
FORCLR:  equ $F3E9  ; Foreground color system variable
GRPACX:  equ $FCB7  ; X position for text output
GRPACY:  equ $FCB9  ; Y position for text output

   OUTPUT "mand2.bin"
   db $fe           ; binary file header
   dw start
   dw end
   dw init

   org $c000

start:
   jp init

MAND_WIDTH  = 64
MAND_HEIGHT = 44
MAND_MAX_IT = 17

   include "../Z80/mandelbrot.asm"

ROM_CLS           = $0DAF

chunks:
    db $00,$00,$00,$00
    db $00,$44,$00,$00
    db $00,$44,$00,$11
    db $00,$44,$00,$55
    db $00,$55,$00,$55
    db $22,$55,$00,$55
    db $22,$55,$88,$55
    db $aa,$55,$88,$55
    db $aa,$55,$aa,$55
    db $aa,$55,$ee,$55
    db $bb,$55,$ee,$55
    db $ff,$55,$ee,$55
    db $ff,$55,$ff,$55
    db $ff,$55,$ff,$dd
    db $ff,$77,$ff,$dd
    db $ff,$77,$ff,$ff
    db $ff,$ff,$ff,$ff


init:
    di
    ld a,2               ; screen mode 2 = 256x192 characters
    call CHGMOD          ; BIOS routine to set screen mode
    ld hl,(GRPCOL)       ; HL = address in vram for color attributes
    ld bc,$1800          ; BC = color attributes area size
    ld a,$1e             ; A = color (lightgray background, black fireground)
    call FILVRM          ; fill attributes area in vram with color in A
    ld bc,0              ; X = 0, Y = 0
.loopm:
    call mand_get
    add a,a
    add a,a
    ld e,a
    ld d,0
    ld ix,chunks
    add ix,de            ; IX = address of chunks table

    ld l,b               ; L = X
    srl l                ; L = X/2
    ld d,$f0             ; D = chunk mask for odd X
    jp nc,.loopm1
    ld d,$0f             ; D = chunk mask for even X
.loopm1:
    ld a,d               ; make inverted mask
    cpl
    ld e,a
    ld hl,(GRPCGP)       ; HL = address of bitmap in vram
                         ; calc low half of video memory address
    ld a,b               ; A = X
    res 0,a              ; lowest bit is not needed
    add a,a
    add a,a              ; A = X*4,  3 lowest bits set to zero
    add a,l              ;
    ld l,a               ; L = int(X/2) * 8

    ld a,c               ; A = Y
    srl a                ; A = Y/2 c-flag is set if Y is odd
    jr nc,.loopm3        ; continue if Y is even
    set 2,l              ; set bit 2 in low half of screen addres, which shifts it 4 pixels down
.loopm3
    add a,h              ; H = H + Y/2
    ld h,a               ; HL = address in video memory for pixes

    push bc              ; preserve BC on stack
    ld b,4               ; B = counter
.loopm2
    call RDVRM           ; load byte from video memory
    and e                ; mask out bits using inverted mask
    ld c,a               ; store for a while
    ld a,(ix)            ; load byte from chunks table
    and d                ; mask out unneeded bits
    or c                 ; combine with masked byte from video memory
    call WRTVRM          ; store to video memory
    inc ix               ; next byte in chunks table
    inc l                ; next line on screen
    djnz .loopm2         ; repeat 4 times
    pop bc
    inc b                ; increment X
    ld a,MAND_WIDTH
    cp b
    jp nz,.loopm         ; loop until X = width
    ld b,0               ; X = 0
    inc c                ; increment Y
    ld a,MAND_HEIGHT
    cp c
    jp nz,.loopm         ; loop until Y = height
    ei
                         ; we cannot just return to basic prompt
                         ; with active screen mode 2
                         ; so must wait for key press
    ld hl,0              ; set X position for print = 0
    ld (GRPACX),hl
    ld hl,184            ; set X position for print = 184
    ld (GRPACY),hl
    ld a,(FORCLR)        ; get text color from system variable
    push af              ; store it on stack
    ld a,1               ; set black color for text
    ld (FORCLR),a
    ld hl,text2
    call print_str       ; print string "Press a key to exit
    pop af               ; restore default text color
    ld (FORCLR),a
    call CHGET           ; wait for key press
    ret

print_str:
    ld a,(hl)
    inc hl
    or a
    ret z
    call GRPPRT
    jp print_str

text2:
    db "Press any key to exit",0
end:
