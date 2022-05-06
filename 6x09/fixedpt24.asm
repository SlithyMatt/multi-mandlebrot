;;; Supplementary routines to allow for 16.8 fixed point intermediates
;;; in some calculations and for some possibly cheating optimization
;;; of mandlebrot calculation.
	ifndef FIXEDPT24_INC
FIXEDPT24_INC equ 1

	include "fixedpt.asm"
	
	;; multiply unsigned 8.8 fixed point value by 16-bit integer
	;; (unsigned) to give unsigned 16.8 fixed point result.
	;; d: 8.8 fixed point value
	;; (y): 16-bit integer
	;; (u): 16.8 fixed point value
	ifdef h6309
FP24_MULTIPLY	macro	; (u)=d*(y)
	muld ,y
	stb ,u
	stw 1,u
	endm
	else ; ! h6309 -> m6809
FP24_MULTIPLY	macro	; (u)=d*(y)
	lbsr fp24_mult
	endm
	
fp24_mult:
	bra fp24_mult
	std FP_T0
	clr ,u
	clr 1,u
	lda 1,y
	mul
	sta 2,u
	lda 1,y
	ldb ,s
	mul
	addd 1,u
	std 1,u
	lda ,y
	ldb 1,s
	mul
	addd 1,u
	std 1,u
	lda ,y
	ldb ,s
	mul
	addd ,u
	std ,u
	rts
	endif ; m6809

	;; divide unsigned 16.8 fixed point value by 16-bit integer
	;; (unsigned) to give 8.8 fixed point result.
	;; (u): 16.8 fixed point value
	;; (y): 16-bit integer
	;; d: 8.8 fixed point dividend
	ifdef h6309
FP24_DIVIDE	macro	; d=(u)/(y)
	ldq -1,u
	clra
	divq ,y
	tfr w,d
	endm
	else ; ! h6309 -> m6809
FP24_DIVIDE	macro	; d=(u)/(y)
	lbsr fp24_div
	endm
	
fp24_div:
	clr FP_T0
	ldd ,u
	std FP_T0+1
	lda 2,u
	sta FP_T1+1
	ldx #16
loop@:	
	asl FP_T1+1
	rol FP_T1
	rol FP_T0+1
	rol FP_T0
	ldd FP_T0
	subd ,y
	blt skip@
	std FP_T0
	inc FP_T1+1
skip@:
	leax -1,x
	bne loop@
	ldd FP_T1
	rts
	endif ; m6809

	;; squares signed 8.8 fixed point numbers. Faster than
	;; multiplying in many cases because: 1) only need to perform
	;; absolute value of one number, 2) result will always be
	;; positive, 3) an 8x8 multiply can be removed because
	;; a*b=b*a. For paired product: $FF*$FF=$FE01, $7F*$FF=$7E81,
	;; *2=$FD02, $FD02+$00FE=$FE00, so no carry from 16-bit sum.
	ifdef h6309
FP_SQUARE	macro	; d=d*d
	std FP_RE
	muld FP_RE
	tfr b,a
	tfr e,b
	endm
	else ; ! h6309 -> m6809
FP_SQUARE	macro	; d=d*d
	lbsr fp_sq
	endm

fp_sq:
	tsta
	bpl skip@
	coma
	comb
	addd #1
skip@:	
	std FP_T0
	tfr b,a
	mul
	clr FP_T1
	sta FP_T1+1
	ldd FP_T0
	mul
	aslb
	rola
	addd FP_T1
	std FP_T1
	lda FP_T0
	tfr a,b
	mul
	addb FP_T1
	tfr b,a
	lda FP_T1+1
	rts
	endif ; m6809
	
	endif ; !FIXEDPT24_INC

