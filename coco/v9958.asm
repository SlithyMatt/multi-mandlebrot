MPI:	equ 1
MAND_MAX_IT:	equ 14
	include "supersprite.asm"
	ifdef MPI
oldmpi:	fdb $00
	endif

setup:
	ifdef h6309
	ldmd #1			; 6309 native mode
	endif
	ifdef MPI
;; switch mpi slot to 0
	lda mpireg
	sta oldmpi
	clr mpireg
	endif
	clr vidmux

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

;; set video registers
	ldx #vregs
loop@:
	lda ,x+
	sta vidreg
	cmpx #endvreg
	bne loop@

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
	rts
vregs:
	fdb $0080,$4081		; mode=$000, G1
	fdb $0482		; patLayout=$01000
	fdb $0084		; patGenTab=$00000
	fdb $2888		; 64k, color 0=palette
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
	fcb $11,$22,$33,$44,$55,$66,$77,$88
	fcb $99,$aa,$bb,$cc,$dd,$ee,$ff,$11
	fcb $22,$33,$44,$55,$66,$77,$88,$99
	fcb $aa,$bb,$cc,$dd,$ee,$ff,$11,$22
endcol	equ *

plot:	
	;; assumes calls are ordered in memory order
	;; assumed that enough time will pass that the V9958 can keep up
	ldx #coltab
	lda #MAND_MAX_IT
	suba 6,s
	anda #$0f
	lda a,x
	sta vram
	rts
coltab:
	fcb $00,$08,$10,$18,$20,$28,$30,$38
	fcb $40,$48,$50,$58,$60,$68,$70,$78
	
restore:
	ifdef MPI 
;; restore mpi slot
	lda oldmpi
	sta mpireg
	endif
	ifdef h6309
	ldmd #0			; 6809 mode
	endif
	rts
