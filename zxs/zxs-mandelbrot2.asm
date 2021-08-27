   DEVICE ZXSPECTRUM48

   org $8000

start:
   jp init

mand_width:    equ 64
mand_height:   equ 44
mand_max_it:   equ 17

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
    exx                  ; save hl' register on stack
    push hl              ; to correct return into basic
    call ROM_CLS
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
                         ; calc low half of video memory address
    ld a,c               ; A = Y
    res 0,a              ; odd and even Ys have same low half address
    add a,a
    add a,a
    add a,a
    add a,a              ; A = Y*16 only 4 lowest bits used
    add a,l
    ld l,a               ; L = Y*16 + X/2

    ld h,$40             ; high byte of video memory starting address if Y is even
    ld a,c               ; A = Y
    srl a                ; A = Y/2 c-flag is set if Y is odd
    jr nc,.loopm3        ; continue if Y is even
    ld h,$44             ; load high byte of video memory starting address if Y is odd
.loopm3
    and $18              ; mask out bits of Y not used for high half of address
    add a,h              ; add starting address high byte
    ld h,a               ; HL = address in video memory for pixes


    push bc              ; preserve BC on stack
    ld b,4               ; B = counter
.loopm2
    ld a,(hl)            ; load byte from video memory
    and e                ; mask out bits using inverted mask
    ld c,a               ; store for a while
    ld a,(ix)            ; load byte from chunks table
    and d                ; mask out unneeded bits
    or c                 ; combine with masked byte from video memory
    ld (hl),a            ; store to video memory
    inc ix               ; next byte in chunks table
    inc h                ; next line on screen
    djnz .loopm2         ; repeat 4 times
    pop bc
    inc b                ; increment X
    ld a,mand_width
    cp b
    jp nz,.loopm         ; loop until X = width
    ld b,0               ; X = 0
    inc c                ; increment Y
    ld a,mand_height
    cp c
    jp nz,.loopm         ; loop until Y = height
    pop hl               ; restore hl' register
    exx                  ; from stack
    ret


; Deployment
LENGTH      = $ - start

; option 1: tape
    include TapLib.asm
    MakeTape ZXSPECTRUM48, "man2-48.tap", "man2-48", start, LENGTH, start

; option 2: snapshot
    SAVESNA "man2-48.sna", start
