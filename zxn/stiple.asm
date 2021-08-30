; clears screen to a bright black and white checkerboard
stiple:
	ld hl,$4000
	ld bc,$0018
	ld a,$aa
	call .sub1
	;; ld hl,$5800
	ld bc,$0003
	ld a,$47
	call .sub2
	ret
.sub1:
	ld (hl),a
	inc hl
	djnz .sub1
	cpl
	dec c
	jp nz,.sub1
	ret
.sub2:
	ld (hl),a
	inc hl
	djnz .sub2
	dec c
	jp nz,.sub2
	ret
