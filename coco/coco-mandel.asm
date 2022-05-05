	org $0e00
	ifdef hires
	include "../6x09/mandelbrot24.asm"
	ifdef coco3
	include "gime-hires.asm"
	else
	include "m6847-hires.asm"
	endif
	else
	include "../6x09/mandelbrot.asm"
	ifdef coco3
	include "gime.asm"
	else
	include "m6847.asm"
	endif
	endif
start:
	pshs cc,dp
	orcc #$50		; no interrupts
	ifdef coco3
	lda #$12		; direct page allowing 1024 bytes for code
	else
	lda #$1e
	endif
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
