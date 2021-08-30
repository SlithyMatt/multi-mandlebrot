;   DEVICE ZXSPECTRUM48

   org $100

start:
   jp init

   include "mandelbrot.asm"

i_result: db 0

cout: REPT 1
   ld   e,a
   ld   c,2	; bdos cout
   jp	5	; call bdos
ENDM

init:
   ld bc,0              ; X = 0, Y = 0
.loopm:
   call mand_get
   add  a,' '
   exx
   push af
   call cout
   pop  af
   call cout
   exx
.loopm1:
   inc b                ; increment X
   ld a,MAND_WIDTH
   cp b
   jp nz,.loopm         ; loop until X = width
   ld b,0               ; X = 0
   exx
   ld a,13
   call cout
   ld a,10
   call cout
   exx
   inc c                ; increment Y
   ld a,MAND_HEIGHT
   cp c
   jp nz,.loopm         ; loop until Y = height
   ret

END start
