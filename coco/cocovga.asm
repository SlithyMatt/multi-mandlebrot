	include "cocovga-page.asm"
	ifdef hires
MAND_WIDTH:     equ 128
MAND_HEIGHT:    equ 96
MAND_YMIN:      equ $FEB0
MAND_YMAX:      equ $02A0
MAND_MAX_IT:    equ 48
	endif
screen:	equ $1200
	
setup:
	ifdef fast
	sta $ffd9
	endif
	ifdef h6309
	ldmd #1			; 6309 mode
	endif
	lbsr cocovga 		; set enable extended mode
	;; point to screen
	vdgadr screen
	;; set video mode CG6 (VG6)
	lda $ff22
	anda #$07
	ora #$e8
	sta $ff22
	vdgmode 6
	rts

	ifdef hires
plot:
	lda 5,s
	clrb
	lsra
	rorb
	addb 3,s
	lsra
	rorb
	addd #screen
	tfr d,x
	lda 6,s
	anda #$0f
	eora #$0f
	ldu #nib2byte
	lda a,u
	ldb 3,s
	andb #$01
	bne odd@
even@:
	ldb ,x
	andd #$f00f
	bra write@
odd@:	
	ldb ,x
	andd #$0ff0
write@:	
	stb ,x
	ora ,x
	sta ,x
	rts
	else
plot:
	lda 5,s
	ldb 3,s
	lslb
	addd #screen
	tfr d,x
	lda 6,s
	anda #$0f
	eora #$0f
	ldu #nib2byte
	lda a,u

	clrb
	leax $80,x
loop@:	
	sta b,x
	leax 1,x
	sta b,x
	leax -1,x
	addb #$40
	bne loop@
	rts
	endif
nib2byte:
	fcb $00,$11,$22,$33,$44,$55,$66,$77
	fcb $88,$99,$aa,$bb,$cc,$dd,$ee,$ff
	
restore:	
	ldd #$ff00
	std page0
	bsr cocovga
	
	ifdef h6309
	ldmd #0			; 6809 mode
	endif
	ifdef fast
	sta $ffd8
	endif
	rts

cocovga:
	lda $ff03
	pshs a			; preserve pia b
	ora #$05		; pia b does not set direction, enable vsync irq
	anda #$fd		; trigger on falling edge of vsync
	sta $ff03

	lda $ff02		; clear vsync irq
loop@:
	lda $ff03
	bpl loop@		; wait for vsync irq
	lda $ff02		; clear vsync irq

	;; point at register set at $0e00
	vdgadr page0
	;; combo lock
	lda $ff22
	anda #$07
	ora #$90
	sta $ff22
	anda #$07
	ora #$48
	sta $ff22
	anda #$07
	ora #$a0
	sta $ff22
	anda #$07
	ora #$f8
	sta $ff22
	;; vdg and sam mode 0
	anda #$07
*	ora #$00		; cocovga page 0
	sta $ff22
	vdgmode 0

loop@:
	lda $ff03
	bpl loop@		; wait for vsync irq
	lda $ff02		; clear vsync irq
	puls a
	sta $ff03		; restore pia
	rts
