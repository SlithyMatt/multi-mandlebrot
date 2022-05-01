	.global mandelbrot
	.equ MAND_XMIN,0xFD80	; -2.5
	.equ MAND_XMAX,0x0380	; 3.5
	.equ MAND_YMIN,0xFF00	; -1
	.equ MAND_YMAX,0x0200	; 2
	.equ MAND_WIDTH,32
	.equ MAND_HEIGHT,22
	.equ MAND_MAX_IT,15
mandelbrot:
	; Input:
	;  (a7)  - return address
	;  4(a7) - PX
	;  6(a7) - PY

	; Output:
	;  8(a7) - # iterations executed (0 to MAND_MAX_IT-1)

	; Data use:
	;  d4 - mand_X
	;  d5 - mand_Y
	;  d6 - mand_X0
	;  d7 - mand_Y0

	move.w 4(a7),d0		; d0 = PX/256
	move.w #MAND_XMAX,d6	; d6=Xmax
	muls d0,d6		; d6=PX*Xmax
	move.w #MAND_WIDTH,d0	; d0=width/256
	divs d0,d6		; d6=(PX*Xmax)/Xwid
	add.w #MAND_XMIN,d6	; d6=(PX*Xmax)/Xwid+Xmin=X0

	move.w 6(a7),d0		; d0=PY/256
	move.w #MAND_YMAX,d7	; d7=Ymax
	muls d0,d7		; d7=PY*Ymax
	move.w #MAND_HEIGHT,d0	; d0=height/256
	divs d0,d7		; d7=(PY*Ymax)/Ywid
	add.w #MAND_YMIN,d7	; d7=(PY*Ymax)/Ywid+Ymin=Y0

	moveq #0,d4		; X=0
	moveq #0,d5		; Y=0
	moveq #0,d3		; I=0 (init to 0)
loop:
	move.w d4,d0		; d0=X
	muls d0,d0		; d0=X^2*256
	asr.l #8,d0		; d0=X^2
	move.w d0,d2		; d2=X^2
	move.w d5,d1		; d1=Y
	muls d1,d1		; d1=Y^2*256
	asr.l #8,d1		; d1=Y^2
	add.w d1,d0		; d0=X^2+Y^2
	cmp.w #0x0400,d0 
	bgt.s dec_i		; X^2+Y^2>4?

	sub.w d1,d2		; d2=X^2-Y^2
 	add.w d6,d2		; d2=X^2-Y^2+X0 (temp X)

	muls d4,d5		; d5=X*Y*256
	asr.l #7,d5		; d5=X*Y*2
	add.w d7,d5		; d5=2*X*Y+Y0 (new Y)

	move.w d2,d4		; d4=temp X (new X)
	add.b #1,d3
	cmp.b #MAND_MAX_IT,d3
	beq.s dec_i
	bra loop
dec_i:
	subq.w #1,d3
	move.w d3,8(a7)
	rts