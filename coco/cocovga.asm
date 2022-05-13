	include "cocovga-page.asm"
	ifdef hires
MAND_WIDTH:     equ 128
MAND_HEIGHT:    equ 96
MAND_YMIN:      equ $FEB0
MAND_YMAX:      equ $02A0
MAND_MAX_IT:    equ 48
	endif
setup:
	ifdef h6309
	ldmd #1			; 6309 mode
	endif
	bsr cocovga
	;; point to $1200
	sta $ffc7		; set F0	$0200
	sta $ffc8		; clear F1	$0400
	sta $ffca		; clear F2	$0800
	sta $ffcd		; set F3	$1000
	sta $ffce		; clear F4	$2000
	sta $ffd0		; clear F5	$4000
	sta $ffd2		; clear F6	$8000
	;; set video mode CG6
	lda $ff22
	anda #$07
	ora #$e8
	sta $ff22
	sta $ffc0		; clear V0
	sta $ffc3		; set V1
	sta $ffc5		; set V2
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
	addd #$1200
	tfr d,x
	lda 6,s
	anda #$0f
	ldu #colors
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
	addd #$1200
	tfr d,x
	lda 6,s
	anda #$0f
	ldu #colors
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
colors:
	fcb $00,$11,$22,$33,$44,$55,$66,$77
	fcb $88,$99,$aa,$bb,$cc,$dd,$ee,$ff
	
restore:	
	lda $1000
	sta $1001
	clr $1000
	bsr cocovga
	
	ifdef h6309
	ldmd #0			; 6809 mode
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
	sta $ffc7		; set F0	$0200
	sta $ffc9		; set F1	$0400
	sta $ffcb		; set F2	$0800
	sta $ffcc		; clear F3	$1000
	sta $ffce		; clear F4	$2000
	sta $ffd0		; clear F5	$4000
	sta $ffd2		; clear F6	$8000
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
	sta $ffc0		; clear V0
	sta $ffc2		; clear V1
	sta $ffc4		; clear V2

loop@:
	lda $ff03
	bpl loop@		; wait for vsync irq
	lda $ff02		; clear vsync irq
	puls a
	sta $ff03		; restore pia
	rts
