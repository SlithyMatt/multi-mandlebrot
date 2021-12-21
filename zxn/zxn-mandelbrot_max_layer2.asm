   DEVICE ZXSPECTRUMNEXT

   org $8000

start:
	jp init

MAND_WIDTH  = 256
MAND_HEIGHT = 192
MAND_MAX_IT = 22

	include "../Z80n/mandelbrot24.asm"

LAYER2_START = $4000
NEXT_SLOT    = $8000

i_result: db 0
next_pixel: dw LAYER2_START
next_bank: db 18

init:
   nextreg $07,$03         ; set to 28 MHz
   nextreg $70,$00;10         ; Layer 2: 320x256x8bpp
   ld bc,$123B             ; Layer 2 Access Port
   ld a,$02                ; Display Layer 2
   nextreg $15,$0C         ; place Layer 2 on top
   nextreg $6A,$00         ; 256-color
   nextreg $52,16          ; Set 16k slot 4 to bank 8 (8k slot 2 = 8k bank 16)
   nextreg $53,17          ; (8k slot 7 = 8k bank 17)
   nextreg $42,$FF         ; Palette all-ink
   nextreg $43,$00         ; select ULA palette 1, no ULANext
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
   nextreg $44,%11011011   ; Color 6: gray 6
   nextreg $44,%00000000
   nextreg $44,%11111111   ; Color 7: white
   nextreg $44,%00000001
   nextreg $44,%00100000   ; Color 8: red 1
   nextreg $44,%00000000
   nextreg $44,%01000000   ; Color 9: red 2
   nextreg $44,%00000000
   nextreg $44,%01100000   ; Color 10: red 3
   nextreg $44,%00000000
   nextreg $44,%10000000   ; Color 11: red 4
   nextreg $44,%00000000
   nextreg $44,%10100000   ; Color 12: red 5
   nextreg $44,%00000000
   nextreg $44,%11000000   ; Color 13: red 6
   nextreg $44,%00000000
   nextreg $44,%11100000   ; Color 14: red 7
   nextreg $44,%00000000
   nextreg $44,%00100100   ; Color 15: yellow 1
   nextreg $44,%00000000
   nextreg $44,%01001000   ; Color 16: yellow 2
   nextreg $44,%00000000
   nextreg $44,%01101100   ; Color 17: yellow 3
   nextreg $44,%00000000
   nextreg $44,%10010000   ; Color 18: yellow 4
   nextreg $44,%00000000
   nextreg $44,%10110100   ; Color 19: yellow 5
   nextreg $44,%00000000
   nextreg $44,%11011000   ; Color 20: yellow 6
   nextreg $44,%00000000
   nextreg $44,%11111100   ; Color 21: yellow 7
   nextreg $44,%00000000

   ld bc,0              ; X = 0, Y = 0
.loopm:
   call mand_get
   ld hl,(next_pixel)
   inc a
   cp MAND_MAX_IT
   jp nz,.set_pixel
   ld a,0
.set_pixel
   ld (hl),a
   inc hl
   ld a,0
   or l
   jp nz,.savenext
   ld a,high NEXT_SLOT
   cp h
   jp nz,.savenext
   ld a,(next_bank)
   nextreg $56,a
   inc a
   nextreg $57,a
   inc a
   ld (next_bank),a
   ld hl,LAYER2_START
.savenext
   ld (next_pixel),hl
   inc c                ; increment Y
   ld a,MAND_HEIGHT
   cp c
   jp nz,.loopm         ; loop until Y = height
   ld c,0               ; Y = 0
   inc hl
   inc b                ; increment X
   ld a,low MAND_WIDTH
   cp b
   jp nz,.loopm         ; loop until X = width
.loop_end:
	jp .loop_end
   ret


; Deployment
LENGTH      = $ - start

;;; option 3: nex
	SAVENEX OPEN "man5.nex",start
	SAVENEX AUTO
	SAVENEX CLOSE
