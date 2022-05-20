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
	std FP_AA
	clr ,u
	lda 1,y
	mul
	std 1,u
	lda 1,y
	ldb FP_AA
	mul
	addd ,u
	std ,u
	lda ,y
	ldb FP_AA+1
	mul
	addd ,u
	std ,u
	lda ,y
	ldb FP_AA
	mul
	addb ,u
	stb ,u
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
	clr FP_XT
	lda ,u
	sta FP_XT+1
	ldd 1,u
	sta FP_RE
	ldx #16
loop@:	
	asl FP_RE+1
	rol FP_RE
	rol FP_XT+1
	rol FP_XT
	ldd FP_XT
	subd ,y
	blt skip@
	std FP_XT
	inc FP_RE+1
skip@:
	leax -1,x
	bne loop@
	ldd FP_RE
	rts
	endif ; m6809

	;; squares signed 8.8 fixed point numbers. Faster than
	;; multiplying in many cases because: 1) only need to perform
	;; absolute value of one number, 2) result will always be
	;; positive, 3) an 8x8 multiply can be removed because
	;; a*b=b*a. For paired product: $FF*$FF=$FE01, $7F*$FF=$7E81,
	;; *2=$FD02, $FD02+$00FE=$FE00, so no carry from 16-bit sum.
	ifdef h6309
FP_SQUARE	macro
	std FP_RE
	muld FP_RE
	tfr b,a
	tfr e,b
	endm
	else ; ! h6309 -> m6809
FP_SQUARE	macro
	lbsr fp_sq
	endm

fp_sq:
	tsta
	bge skip@
	coma
	comb
	addd #1
skip@:	
	std FP_AA
	clr FP_RE
	tfr b,a
	mul
	sta FP_RE+1
	ldd FP_AA
	mul
	aslb
	rola
	addd FP_RE
	std FP_RE
	lda FP_AA
	tfr a,b
	mul
	addb FP_RE
	tfr b,a
	ldb FP_RE+1
	rts
	endif ; m6809
	
	endif ; !FIXEDPT24_INC

