	; clear screen
	.global cls
cls:
	moveq #0,d0
        move.l #0x20000,a0
loop:
        move.l d0,(a0)+
        cmp.l #0x28000,a0
        bne loop
        rts
