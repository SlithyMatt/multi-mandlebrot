; Mandelbrot for CP/M
; This version uses VT100 escape codes
; (clear screen)

   org $100

start:
   jp init

   include "mandelbrot.asm"

i_result: db 0

BDOS	EQU 5
COUT	EQU 2
PRINT	EQU 9

cur_dis:db 27,'[?25l',27,'[H',27,'[J$'
cur_ena:db 27,'[?25h$'


init:
   ld de,cur_dis
   ld c, PRINT
   call BDOS

   ld bc,0              ; X = 0, Y = 0

.loopm:
   call mand_get
   add  a,' '

   exx
   ld e,a
   push de
   ld c,COUT
   call BDOS
   pop de
   ld c,COUT
   call BDOS
   exx

.loopm1:
   inc b                ; increment X
   ld a,MAND_WIDTH
   cp b
   jp nz,.loopm         ; loop until X = width
   ld b,0               ; X = 0

   exx
   ld e,13
   ld c,COUT
   call BDOS
   ld e,10
   ld c,COUT
   call BDOS
   exx

   inc c                ; increment Y
   ld a,MAND_HEIGHT
   cp c
   jp nz,.loopm         ; loop until Y = height

   ld de,cur_ena
   ld c, PRINT
   call BDOS
   ret

END start
