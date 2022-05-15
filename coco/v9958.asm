	ifdef hires
MAND_YMIN:	equ $fe8d
MAND_YMAX:	equ $02e6
MAND_WIDTH:	equ 256
MAND_HEIGHT:	equ 212
MAND_MAX_IT:	equ 48
	endif
	include "supersprite.asm"
	ifdef mpi
oldmpi:	fdb $00
	endif

setup:
	ifdef mpi
;; switch mpi slot to 0
	lda mpireg
	sta oldmpi
	clr mpireg
	endif
	clr vidmux

	ifndef hires
;; set palette
	ldd #$0090
	sta vidreg
	stb vidreg
	ldx #palette
loop@:
	lda ,x+
	sta vidpal
	cmpx #endpal
	bne loop@
	endif

;; set video registers
	ldx #vregs
loop@:
	lda ,x+
	sta vidreg
	cmpx #endvreg
	bne loop@

	ifndef hires
;; set colors
	ldx #colors
loop@:	
	lda ,x+
	sta vram
	cmpx #endcol
	bne loop@

;; skip to $01000
	ldd #$008e
	sta vidreg
	stb vidreg
	ldd #$0050
	sta vidreg
	stb vidreg
	endif
	rts
	ifndef hires
vregs:
	fdb $0080,$4081		; mode=$000, G1
	fdb $0482		; patLayout=$01000
	fdb $0084		; patGenTab=$00000
	fdb $2a88		; 64k, color 0=palette, no sprites
	fdb $2083,$008a		; colorTab=$00800
	fdb $f187		; normal fg=15, bg=8
	fdb $8089		; 212 lines
	fdb $0492		; pos=0/0 (center)
	fdb $0099		; no yjk
	fdb $008e,$0048		; set write address $00800
endvreg	equ *
palette:
	fdb $0000,$0000,$0007,$7007,$0700,$7000,$7707,$0707
	fdb $7700,$7004,$1101,$2202,$3303,$4404,$5505,$5505
endpal	equ *
colors:
	fcb $ff,$ee,$dd,$cc,$bb,$aa,$99,$77
	fcb $66,$55,$44,$33,$22,$11,$88,$11
	fcb $22,$33,$44,$55,$66,$77,$88,$99
	fcb $aa,$bb,$cc,$dd,$ee,$ff,$11,$22
endcol	equ *
	else
vregs:
	fdb $0e80,$4081		; mode=$01c, G7
	fdb $1f82		; patLayout=$00000
	fdb $2a88		; 64k, color 0=palette, no sprites
	fdb $0087		; border color=0
	fdb $8089		; 212 lines
	fdb $0492		; pos=0/0 (center)
	fdb $0099		; no yjk
	fdb $008e,$0040		; set write address $00000
endvreg	equ *
	endif
	
plot:	
	;; assumes calls are ordered in memory order
	;; assumed that enough time will pass that the V9958 can keep up
	lda 6,s
	ifndef hires
	ldx #coltab
	anda #$0f
	lda a,x
	endif
	sta vram
	rts
	ifndef hires
coltab:
	fcb $00,$08,$10,$18,$20,$28,$30,$38
	fcb $40,$48,$50,$58,$60,$68,$70,$78
	endif
	
restore:
	lda #$01
	sta vidmux
	ifdef mpi 
;; restore mpi slot
	lda oldmpi
	sta mpireg
	endif
	rts
