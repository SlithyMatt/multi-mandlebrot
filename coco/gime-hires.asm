setup:
	sta $ffd9 		; 1.78 MHz
	ifdef h6309
	ldmd #1			; 6309 mode
	endif
	;; setup memory map 32k from $8000-$ffff is $60000-$67fff
	ldx #$ffa4
	lda #$30
loop@:
	sta ,x
	inca
	leax 1,x
	cmpa #$34
	bne loop@

	;; set video mode (32x24x16)
	lda $ff90
	anda #$7f
	sta $ff90
	lda #$83		; 24 rows (/8), 60Hz, Graphics
	sta $ff98
	lda #$0a		; 192 lines, 32 bytes per row
	sta $ff99
	;; set video address ($60000)
	clr $ff9c
	lda #$c0
	sta $ff9d
	lda #$00
	sta $ff9e

	;; set palette
	ldx #$ffb0
	ldy #colors
	clra
loop@:
	ldb a,y
	stb a,x
	inca
	cmpa #16
	bne loop@
	rts

plot:
	ldx #$8000
	clrb
	lda 3,s
	lsra
	rorb
	lsra
	rorb
	lsra
	rorb
	addb 2,s
	leax d,x
	lda 4,s
	lsla
	lsla
	lsla
	lsla
	sta FP_T7
	lda 4,s
	anda #$0f
	adda FP_T7 
	sta ,x
	rts

colors:
	fcb $3f,$36,$2d,$24,$1b,$12,$09,$8f
	fcb $38,$30,$28,$20,$18,$10,$08,$00

restore:	
	;; restore memory map 32k from $8000-$ffff is $78000-$7ffff
	ldx #$ffa4
	lda #$3c
loop@:
	sta ,x
	inca
	leax 1,x
	cmpa #$40
	bne loop@
	ifdef h6309
	ldmd #0			; 6809 mode
	endif
	sta $ffd8		; 0.89 MHz
	rts
