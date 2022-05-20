	include "fixedpt.asm"

	ifndef MAND_XMIN
MAND_XMIN equ $FD80 ; -2.5
	endif
	ifndef MAND_XMAX
MAND_XMAX equ $0380 ; 3.5
	endif
	ifndef MAND_YMIN
MAND_YMIN equ $FF00 ; -1
	endif
	ifndef MAND_YMAX
MAND_YMAX equ $0200 ; 2
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
	
mand_get:
	; Input:
        ;  X,Y - bitmap coordinates
        ; Output: A - # iterations executed (0 to MAND_MAX_IT-1)
	lda 3,s
	FP_LD_BYTE
	FP_MULTIPLY #MAND_XMAX  ; C = A*B
	FP_DIVIDE #MAND_WIDTH    ; C = A/B
	FP_ADD #MAND_XMIN       ; C = A+B (scaled X)
	FP_ST mand_x0    ; x0 = C

	lda 5,s
	FP_LD_BYTE   ; A = Y coordinate
	FP_MULTIPLY #MAND_YMAX  ; C = A*B
	FP_DIVIDE   #MAND_HEIGHT  ; C = A/B
	FP_ADD #MAND_YMIN       ; C = A+B (scaled Y)
	FP_ST mand_y0    ; y0 = C

	endif			; divide
	ldd #0
	std mand_x
	std mand_y
	ldy #0
@loop:
	FP_LD mand_x
	FP_MULTIPLY mand_x
	FP_ST mand_x2
	FP_LD mand_y
	FP_MULTIPLY mand_y
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
