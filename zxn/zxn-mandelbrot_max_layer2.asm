   DEVICE ZXSPECTRUMNEXT

   org $8000

start:
	jp init

MAND_WIDTH  = 320
MAND_HEIGHT = 256
MAND_MAX_IT = 48

	include "../Z80n/mandelbrot24.asm"

LAYER2_START = $4000
NEXT_SLOT    = $8000

i_result: db 0
next_pixel: dw LAYER2_START
next_bank: db 18

init:
   nextreg $07,$03         ; set to 28 MHz
   nextreg $70,$10         ; Layer 2: 320x256x8bpp
   ld bc,$123B             ; Layer 2 Access Port
   ld a,$02                ; Display Layer 2
   out (c),a
   nextreg $15,$0C         ; place Layer 2 on top
   nextreg $6A,$00         ; 256-color
   nextreg $52,16          ; Set 16k slot 2 to bank 8 (8k slot 2 = 8k bank 16)
   nextreg $53,17          ; (8k slot 3 = 8k bank 17)
   nextreg $12,8           ; Start Layer 2 RAM at bank 8
   nextreg $1C,1           ; Set Layer 2 Clip Window
   nextreg $18,0           ; X1 = 0
   nextreg $18,159         ; X2 = 159
   nextreg $18,0           ; Y1 = 0
   nextreg $18,255         ; Y2 = 255
   ld bc,0                 ; X = 0, Y = 0
   ld (mand_x),bc
   ld (mand_y),bc
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
   nextreg $52,a
   inc a
   nextreg $53,a
   inc a
   ld (next_bank),a
   ld hl,LAYER2_START
.savenext
   ld (next_pixel),hl
   ld bc,(mand_y)
   inc bc
   ld (mand_y),bc       ; increment Y
   ld a,high MAND_HEIGHT
   cp b
   jp nz,.loopm         ; loop until Y = height
   ld a,low MAND_HEIGHT
   cp c
   jp nz,.loopm         ; loop until Y = height
   ld bc,0
   ld (mand_y),bc       ; Y = 0
   inc hl
   ld bc,(mand_x)
   inc bc
   ld (mand_x),bc       ; increment X
   ld a,high MAND_WIDTH
   cp b
   jp nz,.loopm         ; loop until X = width
   ld a,low MAND_WIDTH
   cp c
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
