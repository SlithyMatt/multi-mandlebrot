.assume adl=0
.org $1000

MAND_XMIN: equ $FD80 ; -2.5
MAND_XMAX: equ $0380 ; 3.5
MAND_YMIN: equ $FF00 ; -1
MAND_YMAX: equ $0200 ; 2

MAND_WIDTH: equ 32
MAND_HEIGHT: equ 22
MAND_MAX_IT: equ 15

plot:
   ld bc,0              ; X = 0, Y = 0
@loop:
   call mand_get
   ld e,a               ; e = num iterations
   ld a,17              ; set color
   rst.lil $10
   ld a,e
   rst.lil $10              ; color index = number of iterations
   ld a,255
   rst.lil $10              ; print solid block
   inc b                ; increment X
   ld a,MAND_WIDTH
   cp b
   jp nz,@loop      ; loop until X = width
   ld b,0               ; X = 0
   ld a,13
   rst.lil $10          ; CR
   ld a,10
   rst.lil $10          ; LF
   inc c                ; increment Y
   ld a,MAND_HEIGHT
   cp c
   jp nz,@loop      ; loop until Y = height
   ret

.include "z80-mandelbrot.asm"
