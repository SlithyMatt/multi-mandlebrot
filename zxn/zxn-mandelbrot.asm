   DEVICE ZXSPECTRUMNEXT

   org $8000

start:
	call stiple
	jp init

	include "../Z80n/mandelbrot.asm"
	include "stiple.asm"

SCREEN_PIXELS     = $4000
COLOR_MAP         = $5800


i_result: db 0

color_codes:
   db $10,$20,$30,$40,$50,$60,$70,$80
   db $90,$A0,$B0,$C0,$D0,$E0,$00

init:
   nextreg $07,$03      ; set to 28 MHz
   exx                  ; save hl' register on stack
	push hl              ; to correct return into basic
   ld hl,SCREEN_PIXELS          ; clear all pixels
   ld (hl),0
   ld de,SCREEN_PIXELS+1
   ld bc,$1800
   ldir
   nextreg $43,$01      ; enable enhanced ULA, first ULA palette, auto-increment
   nextreg $42,%00001111   ; 16/16 color mode
   nextreg $40,128         ; start with paper color 0
   nextreg $44,%00000000   ; Paper Color 0: black
   nextreg $44,%00000000
   nextreg $44,%00100100   ; Paper Color 1: gray 1
   nextreg $44,%00000001
   nextreg $44,%01001001   ; Paper Color 2: gray 2
   nextreg $44,%00000000
   nextreg $44,%01101101   ; Paper Color 3: gray 3
   nextreg $44,%00000001
   nextreg $44,%10010010   ; Paper Color 4: gray 4
   nextreg $44,%00000000
   nextreg $44,%10110110   ; Paper Color 5: gray 5
   nextreg $44,%00000001
   nextreg $44,%10010010   ; Paper Color 4: gray 4
   nextreg $44,%00000000
   nextreg $44,%10110110   ; Paper Color 5: gray 5
   nextreg $44,%00000001
   nextreg $44,%11011011   ; Paper Color 6: gray 6
   nextreg $44,%00000000
   nextreg $44,%11111111   ; Paper Color 7: white
   nextreg $44,%00000001
   nextreg $44,%00100100   ; Paper Color 8: yellow 1
   nextreg $44,%00000000
   nextreg $44,%01001000   ; Paper Color 9: yellow 2
   nextreg $44,%00000000
   nextreg $44,%01101100   ; Paper Color 10: yellow 3
   nextreg $44,%00000000
   nextreg $44,%10010000   ; Paper Color 11: yellow 4
   nextreg $44,%00000000
   nextreg $44,%10110100   ; Paper Color 12: yellow 5
   nextreg $44,%00000000
   nextreg $44,%11011000   ; Paper Color 13: yellow 6
   nextreg $44,%00000000
   nextreg $44,%11111100   ; Paper Color 14: yellow 7
   nextreg $44,%00000000
   nextreg $44,%00100000   ; Paper Color 15: red 1
   nextreg $44,%00000000

   ld bc,0              ; X = 0, Y = 0
.loopm:
   call mand_get
   ld h,0
   ld l,c               ; HL = Y
   add hl,hl
   add hl,hl
   add hl,hl
   add hl,hl
   add hl,hl            ; HL = Y*32
   ld de,COLOR_MAP
   add hl,de            ; HL = COLOR_MAP+Y*32
   ld d,0
   ld e,b               ; DE = X
   add hl,de            ; HL = color attribute (x,y)
   ex de,hl
   ld hl,color_codes
   add a,l              ; DE = I
   ld l,a
   jp nc,.loopm1
   inc h
.loopm1:
   ;add ix,de            ; IX = &(color code for I)
   ld a,(hl)            ; A = color code for I
   ld (de),a            ; set color code
   inc b                ; increment X
   ld a,MAND_WIDTH
   cp b
   jp nz,.loopm         ; loop until X = width
   ld b,0               ; X = 0
   inc c                ; increment Y
   ld a,MAND_HEIGHT
   cp c
   jp nz,.loopm         ; loop until Y = height
   pop hl               ; restore hl' register
	exx                  ; from stack
.loop_end:
	jp .loop_end
   ret


; Deployment
LENGTH      = $ - start

;;; option 3: nex
	SAVENEX OPEN "man.nex",start
	SAVENEX AUTO
	SAVENEX CLOSE
