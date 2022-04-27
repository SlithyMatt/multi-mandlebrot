	.global mandel_pt
mandel_pt:
	move.w 4(a7),d0
	mulu 6(a7),d0
	andi.w #0x000f,d0
	move.w d0,8(a7)
	rts
