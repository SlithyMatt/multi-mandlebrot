MAND_WIDTH:	equ 128
MAND_HEIGHT:	equ 192
MAND_YMIN:	equ $FEB0
MAND_YMAX:	equ $02A0
MAND_MAX_IT:	equ 48
screen:	equ $1200
	
setup:
	ifdef h6309
	ldmd #1			; 6309 native mode
	endif
	;;  CG3
	lda $ff22
	anda #$07
	ora #$e8
	sta $ff22
	vdgmode 6
	vdgadr screen
	rts

plot:
	ldd 4,s
	exg a,b
	lsra
	rorb
	addd 2,s
	lsra
	rorb
	lsra
	rorb
	addd #screen
	tfr d,x
	lda #$c0
	ldb 3,s
	andb #$03
	beq skip@
loop@:
	lsra
	lsra
	decb
	bne loop@
skip@:
	tfr a,b
	coma
	anda ,x
	sta ,x
	lda 6,s
	anda #$03
	ldy #colors
	andb a,y
	orb ,x
	stb ,x
	rts
colors:
	fcb $aa,$ff,$55,$00

restore:
	ifdef h6309
	ldmd #0			; 6809 mode
	endif
	rts
