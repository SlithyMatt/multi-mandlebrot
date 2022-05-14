screen:	equ $1200
	
setup:
	ifdef h6309
	ldmd #1			; 6309 native mode
	endif
	;;  SG12
	lda $ff22
	anda #7
	sta $ff22
	vdgmode 4
	vdgadr screen
	rts

plot:
	lda 5,s
	clrb
	lsra
	rorb
	orb 3,s
	addd #screen
	tfr d,x
	lda 6,s
	anda #$0f
	ldy #colors
	lda a,y
	sta ,x
	sta $20,x
	sta $40,x
	sta $60,x
	rts
colors:
	fcb $ff,$ef,$df,$cf,$bf,$af,$9f,$8f
	fcb $20,$ff,$ef,$df,$cf,$bf,$cf,$80

restore:
	ifdef h6309
	ldmd #0			; 6809 mode
	endif
	rts
