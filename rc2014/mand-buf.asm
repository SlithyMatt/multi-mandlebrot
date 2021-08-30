;
; Mandelbrot for CP/m
; version with output buffering
;

   org $100

start:
   jp init

   include "mandelbrot.asm"

i_result: db 0

BDOS	EQU	5
COUT	EQU	2

cursor:	ds 2
buff:	ds MAND_WIDTH*2
	db 13,10,0

println: REPT 1
	LOCAL printc

	ld hl,buff
	ld (cursor),hl

	printc:
		ld a,(hl)
		cp 0
		ret z
		exx
		ld e,a
		ld c,COUT
		call BDOS
		exx
		inc hl
	jr printc
ENDM


init:
   ld hl,buff
   ld (cursor),hl
   ld bc,0              ; X = 0, Y = 0
.loopm:
   call mand_get

   add  a,' '
   ld hl,(cursor)
   ld (hl),a
   inc hl
   ld (hl),a
   inc hl
   ld (cursor),hl

.loopm1:
   inc b                ; increment X
   ld a,MAND_WIDTH
   cp b
   jp nz,.loopm         ; loop until X = width
   ld b,0               ; X = 0
   inc c                ; increment Y
   call println
   ld a,MAND_HEIGHT
   cp c
   jp nz,.loopm         ; loop until Y = height
   ret

END start
