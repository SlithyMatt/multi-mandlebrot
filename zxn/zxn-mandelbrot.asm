   DEVICE ZXSPECTRUMNEXT

   org $8000

start:
	call stiple
	jp init

	include "../Z80n/mandelbrot.asm"
	include "stiple.asm"

ROM_CLS           = $0DAF

COLOR_MAP         = $5800


i_result: db 0

color_codes:
   db 0,8,16,24,32,40,48,56
   db 72,80,88,96,104,112,120

init:
   nextreg $07,$03      ; set to 28 MHz
   exx                  ; save hl' register on stack
	push hl              ; to correct return into basic
   nextreg $43,$01      ; enable ULAnext, first ULA palette, auto-increment
   nextreg $42,15       ; 16 color mode
   nextreg $44,%00000000   ; Color 0: black
   nextreg $44,%00000000
   nextreg $44,%00100100   ; Color 1: gray 1
   nextreg $44,%00000001
   nextreg $44,%01001001   ; Color 2: gray 2
   nextreg $44,%00000000
   nextreg $44,%01101101   ; Color 3: gray 3
   nextreg $44,%00000001
   nextreg $44,%10010010   ; Color 4: gray 4
   nextreg $44,%00000000
   nextreg $44,%10110110   ; Color 5: gray 5
   nextreg $44,%00000001
   nextreg $44,%10010010   ; Color 4: gray 4
   nextreg $44,%00000000
   nextreg $44,%10110110   ; Color 5: gray 5
   nextreg $44,%00000001
   nextreg $44,%11011011   ; Color 6: gray 6
   nextreg $44,%00000000
   nextreg $44,%11111111   ; Color 7: white
   nextreg $44,%00000001
   nextreg $44,%00100100   ; Color 8: yellow 1
   nextreg $44,%00000000
   nextreg $44,%01001000   ; Color 9: yellow 2
   nextreg $44,%00000000
   nextreg $44,%01101100   ; Color 10: yellow 3
   nextreg $44,%00000000
   nextreg $44,%10010000   ; Color 11: yellow 4
   nextreg $44,%00000000
   nextreg $44,%10110100   ; Color 12: yellow 5
   nextreg $44,%00000000
   nextreg $44,%11011000   ; Color 13: yellow 6
   nextreg $44,%00000000
   nextreg $44,%11111100   ; Color 14: yellow 7
   nextreg $44,%00000000
   nextreg $44,%00100000   ; Color 15: red 1
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
