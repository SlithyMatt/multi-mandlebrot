	org $0e00
mpi:	equ 1			; mpi present
vdgadr	macro
	sta $ffc6+(1&&(\1&$0200)) ; F0
	sta $ffc8+(1&&(\1&$0400)) ; F1
	sta $ffca+(1&&(\1&$0800)) ; F2
	sta $ffcc+(1&&(\1&$1000)) ; F3
	sta $ffce+(1&&(\1&$2000)) ; F4
	sta $ffd0+(1&&(\1&$4000)) ; F5
	sta $ffd2+(1&&(\1&$8000)) ; F6
	endm

vdgmode macro
	sta $ffc0+(1&&(\1&1)) 	; V0
	sta $ffc2+(1&&(\1&2)) 	; V1
	sta $ffc4+(1&&(\1&4)) 	; V2
	endm

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
