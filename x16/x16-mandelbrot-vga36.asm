.org $080D
.segment "STARTUP"
.segment "INIT"
.segment "ONCE"
.segment "CODE"

   jmp start

MAND_YMIN = $FFFE8A ; -1.4609375
MAND_YMAX = $0002EB ; 2.91796875
MAND_WIDTH = 36
MAND_HEIGHT = 30
MAND_MAX_IT = 48

.include "../6502/mandelbrot.asm"

VERA_ctrl         = $9F25
VERA_addr_low     = $9F20
VERA_addr_high    = $9F21
VERA_addr_bank    = $9F22
VERA_data0        = $9F23
VERA_dc_video     = $9F29
VERA_dc_hscale    = $9F2A
VERA_dc_vscale    = $9F2B
VERA_L0_config    = $9F2D
VERA_L0_tilebase  = $9F2F
VERA_L1_config    = $9F34

PLOT              = $FFF0

VRAM_BITMAP       = $04000

start:
   lda #8              ; 16x scale (40x30 pixels)
   sta VERA_dc_hscale
   sta VERA_dc_vscale
   lda #$68
   sta VERA_L1_config
   lda #$07
   sta VERA_L0_config
   lda #(VRAM_BITMAP >> 9)
   sta VERA_L0_tilebase
   lda #$11
   sta VERA_dc_video
   stz VERA_ctrl
   lda #($10 | ^VRAM_BITMAP)
   sta VERA_addr_bank   ; stride = 1, bank 0
   lda #>VRAM_BITMAP
   sta VERA_addr_high
   lda #<VRAM_BITMAP
   sta VERA_addr_low
   ldx #0
   ldy #0
@loop:
   jsr mand_get
   clc
   cmp #(MAND_MAX_IT-1)
   bne @offset
   lda #0
   bra @set_pixel
@offset:
   adc #80
   cmp #128
   bne @set_pixel
   lda #0
@set_pixel:
   sta VERA_data0
   inx
   cpx #MAND_WIDTH
   bne @loop
   ldx #0
@blank_loop1:
   stz VERA_data0
   dex
   bne @blank_loop1
   ldx #(320-256-MAND_WIDTH)
@blank_loop2:
   stz VERA_data0
   dex
   bne @blank_loop2
   iny
   cpy #MAND_HEIGHT
   bne @loop
   clc
   tya
   tax
   ldy #0
   jsr PLOT
   rts
