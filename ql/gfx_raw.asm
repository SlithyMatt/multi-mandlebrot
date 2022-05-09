	.global MAND_XMIN,MAND_XMAX,MAND_YMIN,MAND_YMAX
	.global MAND_WIDTH,MAND_HEIGHT,MAND_MAX_IT
	.equ MAND_XMIN,0xFD80    ; -2.5
	.equ MAND_XMAX,0x0380    ; 3.5
	.equ MAND_YMIN,0xFF00    ; -1
	.equ MAND_YMAX,0x0200    ; 2
	.equ MAND_WIDTH,32
	.equ MAND_HEIGHT,22
	.equ MAND_MAX_IT,15
	.global setup,plot,restore
setup:
	rts
	
plot:
	move.w 4(a7),d2 ; px
	move.w 6(a7),d1 ; py
	move.w 8(a7),d0 ; i
	asl.w #2,d0
	lea colors(PC),a0
	move.l 0(a0,d0.w),d6
	move.l 64(a0,d0.w),d7
	mulu #0x500,d1
	asl.w #2,d2
	add.w d2,d1
	addi.w #128,d1
	move.l #0x20000,a0
	moveq #5,d0
loop:
	move.l d6,-128(a0,d1.w)
	move.l d7,0(a0,d1.w)
	addi.w #256,d1
	subq.w #1,d0
	bne loop
	rts
colors: .long 0x00000000,0x00110011,0x00550055,0x00660066
	.long 0x00aa00aa,0x00bb00bb,0x00ff00ff,0x22cc22cc
	.long 0xaa00aa00,0xaa11aa11,0xaa55aa55,0xaa66aa66
	.long 0xaaaaaaaa,0xaabbaabb,0xaaffaaff,0x88cc88cc
	.long 0x00000000,0x00440044,0x00550055,0x00990099
	.long 0x00aa00aa,0x00ee00ee,0x00ff00ff,0x88338833
	.long 0xaa00aa00,0xaa44aa44,0xaa55aa55,0xaa99aa99
	.long 0xaaaaaaaa,0xaaeeaaee,0xaaffaaff,0x22332233

restore:
	rts
	
