	org $0e00
	include "../6x09/mandelbrot.asm"
	include "gime.asm"
start:
	pshs cc,dp
	orcc #$50		; no interrupts
	lda #$12		; direct page allowing 1024 bytes for code
	pshs a
	puls dp
	lbsr setup
	
	;; main loop
	leas -3,s
	clra
	sta 1,s
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
	lbsr restore
	puls cc,dp,pc
	end start
