	device zxspectrumnext
	org $8000
start:
	ld hl,$4000
	ld bc,$0018
	ld a,$aa
	call sub1
	;; ld hl,$5800
	ld bc,$0003
	ld a,$47
	call sub2
.loop:
	jp .loop
sub1:
	ld (hl),a
	inc hl
	djnz sub1
	cpl
	dec c
	jp nz,sub1
	ret
sub2:
	ld (hl),a
	inc hl
	djnz sub2
	dec c
	jp nz,sub2
	ret
	savenex open "test.nex",start
	savenex auto
	savenex close
