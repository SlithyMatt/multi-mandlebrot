	org $0e00
start:
	pshs cc,dp
	orcc #$50		; no interrupts
	lda #$1d
	pshs a
	puls dp
	ifdef h6309
	ldmd #1
	endif
	sta $ffd9
	leas -3,s
	;; set video mode (32x24x16)
	lda $ff90
	anda #$7f
	sta $ff90
*	lda $ff98
*	anda #$78
*	ora #$83
	lda #$83		; 24 rows (/8), 60Hz, Graphics
	sta $ff98
*	lda $ff99
*	anda #$80
*	ora #$02
	lda #$0a		; 192 lines, 32 bytes per row
	sta $ff99
	;; set video address ($71200=$1200)
	clr $ff9c
	lda #$e2
	sta $ff9d
	lda #$40
	sta $ff9e

	;; set palette
	ldx #$ffb0
	ldy #colors
	clra
loop@:
	ldb a,y
	stb a,x
	inca
	cmpa #16
	bne loop@

	;; main loop
	clra
	sta 1,s
loop@:
	sta ,s
	lbsr mand_get
	bsr plot
	lda ,s
	inca
	cmpa #32
	bne loop@
	clra
	ldb 1,s
	incb
	stb 1,s
	cmpb #22
	bne loop@

	;; exit
	leas 3,s
done:
	ifdef h6309
	ldmd #0
	endif
	sta $ffd8
	puls cc,dp,pc

plot:
	ldx #$1200
	clrb
	lda 3,s
	lsra
	rorb
	lsra
	rorb
	lsra
	rorb
	addb 2,s
	leax d,x
	lda 4,s
	lsla
	lsla
	lsla
	lsla
	sta FP_T7
	lda 4,s
	anda #$0f
	adda FP_T7 
	sta ,x
	rts

colors:
	fcb $3f,$36,$2d,$24,$1b,$12,$09,$8f
	fcb $38,$30,$28,$20,$18,$10,$08,$00

	include "../6x09/mandelbrot.asm"

	
	end start
