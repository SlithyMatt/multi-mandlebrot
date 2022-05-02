;;; 8.8 fixed point routines for m6809 and h6309
;;; d (a:b) is used as the accumulator
;;; x is a temporary register
;;; all other registers are preserved
;;; 16 bytes of scratch space on direct page
	ifndef FIXEDPT_INC
FIXEDPT_INC equ 1

FP_A	equ $f0			;  a
FP_B	equ $f2			;  b
FP_AA	equ $f4			; |a|
FP_BA	equ $f6			; |b|
FP_XT	equ $f8			; extra (overflow/remainder)
FP_RE	equ $fa			; result
FP_T6	equ $fc
FP_T7	equ $fe

FP_LD_BYTE macro 		; d=a
	clrb
	endm
	
FP_LD macro			; d=(ea) ; fp
	ldd \1
	endm

FP_LD_INT macro			; d=(ea) ; int
	lda \1
	clrb
	endm

FP_ST macro			; (ea)=d
	std \1
	endm

FP_FLOOR macro			; d=floor(d)
	clrb
	endm

FP_SUBTRACT macro		; d=d-(ea)
	subd \1
	endm

FP_ADD macro			; d=d+(ea)
	addd \1
	endm

FP_COMPARE macro		; compare d (set flags)
	cmpd \1
	endm

FP_MUL2 macro			; d=2*d
	aslb
	rola
	endm

FP_NEG macro			; d=-d
	ifdef h6309
	negd
	else ; m6809 - 4/8
	coma
	comb
	addd #1
	endif h6309
	endm

FP_ABS macro			; d=|d|
	tsta
	bpl out@
	FP_NEG
out@:
	endm

FP_ABS1 macro			; d=|(ea)|
	ldd \1
	bpl out@
	FP_NEG
out@:
	endm
	

	ifdef h6309
FP_MULTIPLY macro		; d=d*(ea)
	muld \1
	stq FP_RE-1
	ldd FP_RE
	endm
	else ; m6809
FP_MULTIPLY macro		; d=d*(ea)
	ldx \1
	lbsr fp_mul
	endm

fp_mul: ; d = d * x ; FP_XT overflow
	FP_ST FP_A
	FP_ABS
	FP_ST FP_AA
	tfr x,d
	FP_ST FP_B
	FP_ABS
	FP_ST FP_BA

	FP_LD #$0000
	FP_ST FP_XT
	FP_ST FP_RE
	;; l1*l2
	lda FP_AA+1
	ldb FP_BA+1
	mul
*	addd #$0080 ; round 
	sta FP_RE+1
	;; h1*l2
	lda FP_AA
	ldb FP_BA+1
	mul
	addd FP_RE 		; can't overflow
	std FP_RE
	;; l1*h2
	lda FP_AA+1
	ldb FP_BA
	mul
	addd FP_RE
	std FP_RE
	;; h1*h2
	lda FP_AA
	ldb FP_BA
	mul
	addd FP_RE-1
	std FP_RE-1
	;; adjust sign
	lda FP_A
	eora FP_B
	bpl @retpos
	FP_LD #$0000
	FP_SUBTRACT FP_RE
	rts
@retpos:
	FP_LD FP_RE
	rts
	endif h6309
	
FP_DIVIDE macro 		; d=d/(ea) ; remander in FP_RE
	ldx \1
	lbsr fp_div
	endm
	
fp_div: ; d=d/x ; remainder in FP_XT
	FP_ST FP_A
	FP_ABS
	FP_ST FP_AA
	tfr x,d
	FP_ST FP_B
	FP_ABS
	FP_ST FP_BA

 	ldb FP_BA+1
 	clra
 	FP_ST FP_BA
 	clrb
 	std FP_XT	
 	ldx #16     ;There are 16 bits in C
@loop1:
	FP_LD FP_AA
	aslb    ;Shift hi bit of C into REM
	rola  ;(vacating the lo bit, which will be used for the quotient)
	FP_ST FP_AA
	FP_LD FP_XT
	rolb
	rola
	FP_ST FP_XT
	subd FP_B ;Trial subtraction
	blt @loop2  ;Did subtraction succeed?
	std FP_XT
	inc FP_AA+1    ;and record a 1 in the quotient
@loop2:
 	leax -1,x	
 	bne @loop1
	lda FP_A
	eora FP_B
	blt @retneg
	FP_LD FP_AA
	rts
@retneg:
	FP_LD FP_AA
	FP_NEG
	rts
	endif ; !FIXEDPT_INC
