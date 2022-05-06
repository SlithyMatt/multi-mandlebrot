	org $0e00
	ifdef hires
	ifdef coco3
	include "gime-hires.asm"
	else 
	include "m6847-hires.asm"
	endif
	include "../6x09/mandelbrot24.asm"
	else
	ifdef coco3
	include "gime.asm"
	else
	include "m6847.asm"
	endif
	include "../6x09/mandelbrot.asm"
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
	leas -5,s
	clr ,s
	clr 1,s
	clr 2,s
	clr 3,s
loop@:
	lbsr mand_get
	lbsr plot
	ldd ,s
	addd #1
	std ,s
	cmpd #MAND_WIDTH
	bne loop@
	clr ,s
	clr 1,s
	ldd 2,s
	addd #1
	std 2,s
	cmpd #MAND_HEIGHT
	bne loop@
	leas 5,s

	;; exit
	lbsr restore
	puls cc,dp,pc
	end start
