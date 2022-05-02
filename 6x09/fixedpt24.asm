;;; 8.8 fixed point routines for m6809 and h6309
;;; d (a:b) is used as the accumulator
;;; x is a temporary register
;;; all other registers are preserved
;;; 16 bytes of scratch space on direct page
	ifndef FIXEDPT_INC
FIXEDPT_INC equ 1

FP24_ACC	equ $10			;  a
FP24_OP	equ $13			;  b
FP_AACC	equ $16			; |a|
FP_AOP	equ $19			; |b|
FP_XT	equ $1c			; extra (overflow/remainder)
FP_RE	equ $1f			; result

FP24_LD_WORD macro 		; (u)=(ea) ; int
	ldd \1
	std FP24_ACC
	clr FP24_ACC+1
	ldu #FP24_ACC
	endm
	
FP24_SUBTRACT macro		; (x)=(x)-(y)
	ldd 1,x
	subd 1,y
	std 1,x
	lda ,x
	sbca ,x
	sta ,x
	endm

FP24_ADD macro			; (x)=(x)+(y)
	ldd 1,x
	addd 1,y
	std 1,x
	lda ,x
	adca ,y
	sta ,x
	endm

FP24_NEG macro			; (x)=-(x)
	com ,x
	ldd 1,x
	coma
	comb
	addd #1
	std 1,x
	lda #0
	adca ,x
	sta ,x
	endm

FP24_ABS macro			; (x)=|(x)|
	tst ,x
	bpl out@
	FP24_NEG
out@:
	endm
	
cp_abs:
	lda ,x
	sta ,y
	ldd 1,x
	std 1,y
	tst ,x
	bpl out@
	com ,y
	coma
	comb
	addd #1
	std 1,y
	lda #0
	adca ,y
	sta ,y
out@:
	rts


FP24_MULTIPLY macro		; (x)=(x)*(y)
	leas -8,s
	leau ,s
	lbsr muls24_48
	ldd 2,s
	std ,x
	lda 4,s
	sta 2,x
	leas 8,s
	endm

FP24_DIVIDE macro 		; (x)=(x)/(y) 
	lbsr fp_div
	endm
	
fp_div: ; d=d/x ; remainder in FP24_XT
	pshs y,x
	ldy #FP24_A
	lbsr cp_abs
	ldx ,s
	ldy #FP24_B
	lbsr cp_abs
	ldx #32
loop@:
	asl FP24_A+2
	rol FP24_A+1
	rol FP24_A+1
	rol FP24_R+2
	rol FP24_R+1
	rol FP24_R
	ldd FP24_R+1
	subd FP24_B+1
	std FP24_T+1
	lda FP24_R
	sbca FP24_B
	blt skip@
	sta FP24_R
	ldd FP24_T+1
	std FP24_R
	inc FP24_A+2
skip@:
	leax -1,x
	bne loop@
	ldy 2,s
	ldx FP24_A
	lbsr cp_abs
	puls x,y,pc

muls24_48:
	pshs x,y
	leas -6,s
	ldd ,x
	bpl xpos@
	coma
	comb
	std ,s
	lda 2,x
	nega
	sta 2,s
	ldd ,s
	adcb
	adca
	std ,s
	bra y@
xpos@:
	std ,s
	lda 2,x
	sta 2,s
y@:	
	ldd ,y
	bpl xpos@
	coma
	comb
	std 3,s
	lda 2,y
	nega
	sta 5,s
	ldd ,s
	adcb
	adca
	std 3,s
	bra mul@
ypos@:
	std 3,s
	lda 2,y
	sta 5,s
mul@:
	leax ,s
	leay 3,s
	bsr mulu24_48
	leas 6,s
	puls y,x
	lda ,x
	eora ,y
	bpl return@
	com ,u
	com 1,u
	com 2,u
	com 3,u
	com 4,u
	neg 5,u
	ldd #0
	adcb 4,u
	adca 3,u
	std 3,u
	ldd #0
	adcb 2,u
	adca 1,u
	std 1,u
	lda #0
	adca ,u
	sta ,u
return@:	
	rts
	
mulu24_48:
	;; x points to op1
	;; y points to op2
	;; u points to dest
	ldd #0
	std ,u
	std 2,u
	leau 4,u
	;; 4
	lda 2,x
	ldb 2,y
	mul
	std ,u-
	;; 3
	lda 1,x
	ldb 2,y
	mul
	addd ,u
	std ,u
	lda 2,y
	ldb 1,x
	mul
	addd ,u
	std ,u-
	lda #0
	adca #0
	sta ,u
	;; 2
	lda ,x
	ldb 2,y
	mul
	addd ,u
	std ,u
	lda 1,x
	ldb 1,y
	mul
	addd ,u
	std ,u
	lda #0
	adca -1,u
	sta -1,u
	lda 2,x
	ldb ,y
	mul
	addd ,u
	std ,u-
	lda #0
	adca ,u
	sta ,u
	;; 1
	lda ,x
	ldb 1,y
	mul
	addd ,u
	std ,u
	lda 1,x
	ldb ,y
	mul
	addd ,u
	std ,u-
	lda #0
	adca #0
	sta ,u
	;; 0
	lda ,x
	ldb ,y
	mul
	addd ,u
	std ,u
	rts
	endif ; !FIXEDPT_INC

