	org $0e00
start:
	ifdef h6309
	ldmd #1
	endif
	pshs cc,dp
	orcc #$50		; disable interrupts
	lda #$1d
	pshs a
	puls dp
	leas -3,s
	;;  SG12
	anda #7
	sta $ff22
	sta $ffc0
	sta $ffc2
	sta $ffc5
	;; starting address $1200
	sta $ffc7
	sta $ffc8
	sta $ffca
	sta $ffcd
	sta $ffce
	sta $ffd0
	sta $ffd2
	clr 1,s

	clra
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

	leas 3,s
done:
	ifdef h6309
	ldmd #0
	endif
	puls cc,dp,pc
plot:
	lda 3,s
	clrb
	lsra
	rorb
	orb 2,s
	addd #$1200
	tfr d,x
	lda 4,s
	anda #$0f
	ldy #colors
	lda a,y
	sta ,x
	sta $20,x
	sta $40,x
	sta $60,x
	rts
colors:
	fcb $ff,$ef,$df,$cf,$bf,$af,$9f,$8f
	fcb $20,$ff,$ef,$df,$cf,$bf,$cf,$80

	include "../6x09/mandelbrot.asm"

	end start
