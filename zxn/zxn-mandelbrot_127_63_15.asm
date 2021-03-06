   DEVICE ZXSPECTRUMNEXT

   org $8000

start:
	jp init

MAND_WIDTH  = 127
MAND_HEIGHT = 63
MAND_MAX_IT = 15

	include "../Z80n/mandelbrot.asm"

TOP_PIXELS        = $4000
PIXEL_GAP         = $5800
BOTTOM_PIXELS     = $6000

i_result: db 0
next_pixel: dw TOP_PIXELS

init:
   nextreg $07,$03      ; set to 28 MHz
   exx                  ; save hl' register on stack
	push hl              ; to correct return into basic
   nextreg $15,$80         ; enable LoRes
   nextreg $6A,$00         ; 256-color
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
   ld hl,(next_pixel)
   inc a
   cp MAND_MAX_IT
   jp nz,.set_pixel
   ld a,0
.set_pixel
   ld (hl),a
   inc hl
   ld (next_pixel),hl
   inc b                ; increment X
   ld a,MAND_WIDTH
   cp b
   jp nz,.loopm         ; loop until X = width
   ld b,0               ; X = 0
   inc hl
   ld a,high PIXEL_GAP
   cp h
   jp nz,.nexty
   ld a,low PIXEL_GAP
   cp l
   jp nz,.nexty
   ld hl,BOTTOM_PIXELS
.nexty
   ld (next_pixel),hl
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
	SAVENEX OPEN "man3.nex",start
	SAVENEX AUTO
	SAVENEX CLOSE
