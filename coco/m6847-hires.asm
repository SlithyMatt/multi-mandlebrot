setup:
	ifdef h6309
	ldmd #1			; 6309 native mode
	endif
	;;  SG12
	lda $ff22
	anda #7
	sta $ff22
	sta $ffc0
	sta $ffc2
	sta $ffc5
	;; starting address $1200
	sta $ffc7
	sta $ffc8
	sta $ffca
	sta $ffcd
	sta $ffce
	sta $ffd0
	sta $ffd2
	rts

plot:
	lda 3,s
	clrb
	lsra
	rorb
	orb 2,s
	addd #$1200
	tfr d,x
	lda 4,s
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
