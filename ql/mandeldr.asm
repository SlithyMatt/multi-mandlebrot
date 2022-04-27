	.global cls,mandel_pt,plot
	.global mandelbrot
	; px: (a7)
	; py: 2(a7)
	; i:  4(a7)
mandelbrot:
	subq.l #6,a7
	bsr cls
	moveq #0,d0
	move.w d0,2(a7) ; y
loop:
	move.w d0,(a7) ; x
	bsr mandel_pt
	bsr plot
	move.w (a7),d0
	addq.w #1,d0
	cmpi.w #32,d0
	bne loop
	moveq #0,d0
	move.w 2(a7),d1
	addq.w #1,d1
	move.w d1,2(a7)
	subi.w #22,d1
	bne loop
	addq.l #6,a7
	rts
	
