	org $0e00
screen:	equ $1200
	MAND_WIDTH=32
	MAND_HEIGHT=64
start:
	ifdef h6309
	ldmd #1
	endif
	pshs cc,dp
	orcc #$50		; disable interrupts
	lda #$11
	pshs a
	puls dp
	leas -3,s
	;;  G6C
	lda $ff22
	anda #7
	ora #$e0
	sta $ff22
	sta $ffc0
	sta $ffc3
	sta $ffc5
	;; starting address $1200
	sta $ffc7
	sta $ffc8
	sta $ffca
	sta $ffcd
	sta $ffce
	sta $ffd0
	sta $ffd2

	lbsr cls
	lbra doit
	
	clra
	sta ,s
	stb 1,s
loop@:
	lda ,s
	eora 1,s
	anda #$0f
	sta 2,s
	lbsr plot
	lda ,s
	inca
	sta ,s
	cmpa #MAND_WIDTH
	bne loop@
	lda 1,s
	inca
	sta 1,s
	cmpa #MAND_HEIGHT
	bne loop@

	leas 3,s
	puls cc,dp,pc

doit:	
	clra
	sta ,s
	sta 1,s
loop@:
	lbsr mand_get
	bsr plot
	lda ,s
	inca
	sta ,s
	cmpa #MAND_WIDTH
	bne loop@
	clra
	sta ,s
	ldb 1,s
	incb
	stb 1,s
	cmpb #MAND_HEIGHT
	bne loop@

	leas 3,s
done:
	ifdef h6309
	ldmd #0
	endif
	puls cc,dp,pc

ptmp	.word	0
plot:
	ldx #screen
	ldb 3,s			; y
	lda #32
	mul
	leax d,x
	ldb 2,s			; x
	lsrb
	lsrb
	abx

	lda 4,s
	rora
	rora
	rora
	anda #$c0
	
	ldb 2,s
	andb #$03
	beq cont@
loop@:
	lsra
	lsra
	decb
	bne loop@
cont@:	
	ora ,x
	sta ,x
	rts

cls:
	ldx #screen
	clra
	clrb
loop@:
	std ,x++
	cmpx #screen+6144
	bne loop@
	rts
	
	include "../6x09/mandelbrot.asm"

	end start
