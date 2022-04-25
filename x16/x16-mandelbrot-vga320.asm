.org $080D
.segment "STARTUP"
.segment "INIT"
.segment "ONCE"
.segment "CODE"

   jmp start

.include "../6502/mandelbrot24.asm"

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

VRAM_BITMAP       = $04000

loopx: .word 0
loopy: .word 0

start:
   sei
   lda #$11             ; layer 0 only
   sta VERA_dc_video
   lda #$07             ; 8bpp bitmap
   sta VERA_L0_config
   lda #(VRAM_BITMAP >> 9)
   sta VERA_L0_tilebase
   lda #64              ; 2x scale (320x240 pixels)
   sta VERA_dc_hscale
   sta VERA_dc_vscale
   stz VERA_ctrl
   lda #($10 | ^VRAM_BITMAP)
   sta VERA_addr_bank
   lda #>VRAM_BITMAP
   sta VERA_addr_high
   lda #<VRAM_BITMAP
   sta VERA_addr_low
   stz loopx
   stz loopx+1
   stz loopy
   stz loopy+1
@loop:
   stz mand_x
   lda loopx
   sta mand_x+1
   lda loopx+1
   sta mand_x+2
   stz mand_y
   lda loopy
   sta mand_y+1
   lda loopy+1
   sta mand_y+2
   jsr mand_get
   adc #80
   cmp #128
   bne @write_pixel
   lda #0
@write_pixel:
   sta VERA_data0
   lda loopx
   clc
   adc #1
   sta loopx
   lda loopx+1
   adc #0
   sta loopx+1
   cmp #>MAND_WIDTH
   bne @loop
   lda loopx
   cmp #<MAND_WIDTH
   bne @loop
   stz loopx
   stz loopx+1
   lda loopy
   clc
   adc #1
   sta loopy
   lda loopy+1
   adc #0
   sta loopy+1
   cmp #>MAND_HEIGHT
   bne @loop
   lda loopy
   cmp #<MAND_HEIGHT
   bne @loop
   cli
   rts
