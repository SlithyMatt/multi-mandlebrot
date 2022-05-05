	org $0e00
	include "m6847.asm"
	include "../6x09/mandelbrot.asm"
start:
	pshs cc,dp
	orcc #$50		; disable interrupts
	lda #$1d
	pshs a
	puls dp
	lbsr setup

	;; main loop
	leas -3,s
	clr 1,s
	clra
loop@:
	sta ,s
	lbsr mand_get
	lbsr plot
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

	;; exit
	puls cc,dp,pc
	end start
