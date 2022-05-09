	.global setup,plot,restore
	.global MAND_XMIN,MAND_XMAX,MAND_YMIN,MAND_YMAX
	.global MAND_WIDTH,MAND_HEIGHT,MAND_MAX_IT
	.global mandelbrot
	;; px: (a7)
	;; py: 2(a7)
	;; i:  4(a7)
	bra.s start
	.long 0
	.word 0x4afb,10
	.ascii "mandelbrot"
start:
	bsr setup
	lea -6(sp),sp
	moveq #0,d0
	move.l d0,(sp)
loop:
	bsr mandelbrot
	bsr plot
	addq.w #1,(sp)
	cmpi.w #MAND_WIDTH,(sp)
	bne.s loop
	moveq #0,d0
	move.w d0,(sp)
	addq.w #1,2(sp)
	cmpi.w #MAND_HEIGHT,2(sp)
	bne.s loop
	lea 6(sp),sp
	bsr restore
	rts
