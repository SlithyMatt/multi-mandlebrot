	include "fixedpt24.asm"

	ifndef MAND_XMIN
MAND_XMIN equ $FFFD80 ; -2.5
	endif
	ifndef MAND_XMAX
MAND_XMAX equ $000380 ; 3.5
	endif
	ifndef MAND_YMIN
MAND_YMIN equ $FFFF00 ; -1
	endif
	ifndef MAND_YMAX
MAND_YMAX equ $000200 ; 2
	endif

	ifndef MAND_WIDTH
MAND_WIDTH equ 32
	endif
	ifndef MAND_HEIGHT
MAND_HEIGHT equ 22
	endif
	ifndef MAND_MAX_IT
MAND_MAX_IT equ 15
	endif

mand_x0:	equ $e0
mand_y0:	equ $e2
mand_x:		equ $e4
mand_y:		equ $e6
mand_x2:	equ $e8
mand_y2:	equ $ea
mand_xtemp:	equ $ec
mand_s:		equ $ee

XMIN:	.word MAND_XMIN
XMAX:	.word MAND_XMAX
XWID:	.word MAND_WIDTH
YMIN:	.word MAND_YMIN
YMAX:	.word MAND_YMAX
YHGT:	.word MAND_HEIGHT

mand_get:
	; Input:
        ;  X=(2,s),Y=(4,s) - bitmap coordinates
        ; Output: A=(6,s) - # iterations executed (0 to MAND_MAX_IT-1)
	ldd 2,s
	ldy #XMAX
	ldu #FP_T2
	FP24_MULTIPLY ; (u) = d*(y)
	ldy #XWID
	FP24_DIVIDE ; d = (u)/(y)
	FP_ADD #MAND_XMIN       ; C = A+B (scaled X)
	FP_ST mand_x0    ; x0 = C

	ldd 4,s
	ldy #YMAX
	ldu #FP_T2
	FP24_MULTIPLY ; (u) = d*(y)
	ldy #YHGT
	FP24_DIVIDE ; d = (u)/(y)
	FP_ADD #MAND_YMIN       ; C = A+B (scaled X)
	FP_ST mand_y0    ; y0 = C

	ldd #0
	std mand_x
	std mand_y
	ldy #0
@loop:
	FP_LD mand_x
	FP_SQUARE
	FP_ST mand_x2
	FP_LD mand_y
	FP_SQUARE
	FP_ST mand_y2
	FP_ADD mand_x2
	FP_COMPARE #$0400
	bgt @dec_i
	;; find xtemp
	FP_LD mand_x2
	FP_SUBTRACT mand_y2 	; X^2 - Y^2
	FP_ADD mand_x0       ; X^2 - Y^2 + X0
	FP_ST mand_xtemp ; Xtemp
	;; find y
	FP_LD mand_x     ;  X
	FP_MUL2		 ; 2*X
	fp_multiply mand_y  ; 2*X*Y
	FP_ADD mand_y0        ; 2*X*Y + Y0
	FP_ST mand_y     ; Y = C (2*X*Y + Y0)
	FP_LD mand_xtemp
	FP_ST mand_x
	lda FP_T7
	leay 1,y
	sta FP_T7
	cmpy #MAND_MAX_IT
	bne @loop
@dec_i:
	lda FP_T7
	tfr y,d
	decb
	stb 6,s
	rts
