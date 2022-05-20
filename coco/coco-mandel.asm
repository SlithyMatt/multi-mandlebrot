;;; Clock
;;; - c1mhz:	force 0.89 MHz clock
;;; - c2mhz:	use 1.78 MHz clock
;;; - cfast:	use GIME-X fast clock
;;; CPU (default to Motorola m6809)
;;; - h6309:	support for Hitachi h6309
;;; Graphics (default to m6847)
;;; - coco3:	coco3 gime support
;;; - hires:	use hires for set (otherwise 32x22x14)
;;; - v9958:	SuperSprite FM+/WordPak2+ support
;;; - vga:	cocovga support
;;; Extra
;;; - mpi:	use mpi register range when appropriate (v9958)
	
	org $0e00
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
	ifdef v9958
modeset set 1
	include "v9958.asm"
	endif
	ifdef hires
	ifdef coco3
modeset set 1
	ifndef c1mhz
	ifndef cfast
c2mhz	set 1
	endif
	endif
	include "gime-hires.asm"
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
	ifndef modeset
modeset set 1
	include "m6847.asm"
	endif
	include "../6x09/mandelbrot.asm"
	endif
start:
	ifdef c2mhz
	sta $ffd9		; 1.78 MHz
	endif
	ifdef cfast
	sta $ffd7		; GIME-X fast mode
	sta $ffd9
	endif
	pshs cc,dp
	orcc #$50		; no interrupts
	lda #$11
	pshs a
	puls dp
	ifdef h6309
	ldmd #1 		; h6309 native mode
	endif
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
	ifdef h6309
	ldmd #0			; m6809 mode
	endif
	ifdef c2mhz
	sta $ffd8		; 0.89 MHz
	endif
	ifdef cfast
	sta $ffd6		; 0.89 MHz
	sta $ffd8
	endif
	puls cc,dp,pc
	end start
