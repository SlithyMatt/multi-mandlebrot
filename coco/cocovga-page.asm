	fcb $00			; no reset
	fcb $b8			; enhanced modes, all palettes
	fcb $00			; reserved
	fcb $00			; font - unchanged
	fcb $00			; artifact - unchanged
	fcb $00			; extras - unchanged
	fcb $00			; reserved
	fcb $00			; reserved
	fcb $01			; enhanced modes (VG6)
	zmb 32-9
	;; semigraphics palette (11 entries)
	fdb $0000,$0014,$0280,$0294,$5000,$5014,$5140,$294a,$5294
	fdb $295f,$2bea
	zmb 32-22
	;; artifact/extra palette (5 entries)
	fdb $2bff,$7d4a,$7d5f,$7fea,$7fff
	
