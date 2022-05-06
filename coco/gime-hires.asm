MAND_WIDTH:	equ 320
MAND_HEIGHT:	equ 200
MAND_MAX_IT:	equ 32
	
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

	;; set video mode (320x200x16)
	lda $ff90
	anda #$7f
	sta $ff90
	lda #$80		; 200 rows (/1), 60Hz, Graphics
	sta $ff98
	lda #$3f		; 200 lines, 32 bytes per row
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
	ldd 4,s
	lda #160
	mul
	lslb
	rola
	addd 2,s
	lsra
	rorb
	leax d,x
	lda 3,s
	anda #1
	beq even@
odd@:
	lda ,x
	anda #$f0
	sta FP_T7
	lda 6,s
	anda #$0f
	ora FP_T7
	sta ,x
	rts
even@:
	lda ,x
	anda #$0f
	sta FP_T7
	lda 6,s
	lsla
	lsla
	lsla
	lsla
	ora FP_T7
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
