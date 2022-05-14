page0:	
	fcb $00			; no reset
	fcb $80			; enhanced modes
	fcb $00			; reserved
	fcb $00			; font - unchanged
	fcb $00			; artifact - unchanged
	fcb $00			; extras - unchanged
	fcb $00			; reserved
	fcb $00			; reserved
	fcb $01			; enhanced modes (VG6)
	zmb 64-9
	;; artifact/extra palette (16 entries)
	fdb $8000,$8842,$9084,$98c6,$a108,$a94a,$b18c,$b9ce
	fdb $c631,$ce73,$d6b5,$def7,$e739,$ef7b,$f7bd,$ffff
	fdb $8000,$8014,$8280,$8294,$d000,$d014,$d140,$a94a
	fdb $d294,$a95f,$abea,$abff,$fd4a,$fd5f,$801f,$ffff
	
