	org $0e00
	ifdef vga
modeset set 1
	include "cocovga.asm"
	endif
	ifdef hires
	ifdef coco3
modeset set 1
	include "gime-hires.asm"
	endif
	ifdef v9958
modeset set 1
	include "v9958-hires.asm"
	endif
	ifndef modeset
modeset set 1
	include "m6847-hires.asm"
	endif
	include "../6x09/mandelbrot24.asm"
	else
	ifdef coco3
modeset set 1
	include "gime.asm"
	endif
	ifdef v9958
modeset set 1
	include "v9958.asm"
	endif
	ifndef modeset
modeset set 1
	include "m6847.asm"
	endif
	include "../6x09/mandelbrot.asm"
	endif
start:
	pshs cc,dp
	orcc #$50		; no interrupts
	lda #$11
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
