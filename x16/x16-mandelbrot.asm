.org $080D
.segment "STARTUP"
.segment "INIT"
.segment "ONCE"
.segment "CODE"

   jmp start

.include "../6502/mandelbrot.asm"

VERA_ctrl         = $9F25
VERA_addr_low     = $9F20
VERA_addr_high    = $9F21
VERA_addr_bank    = $9F22
VERA_data0        = $9F23
VERA_dc_hscale    = $9F2A
VERA_dc_vscale    = $9F2B

PLOT              = $FFF0

start:
   lda #64              ; 2x scale (40x30 characters)
   sta VERA_dc_hscale
   sta VERA_dc_vscale
   ldx #0
   ldy #0
@loop:
   lda mand_max_it
   jsr mand_get
   pha                  ; push I to stack
   stz VERA_ctrl
   lda #$10
   sta VERA_addr_bank   ; stride = 1, bank 0
   sty VERA_addr_high
   txa
   asl
   sta VERA_addr_low
   lda #$20
   sta VERA_data0       ; Character = SPACE
   pla                  ; retrieve I
   asl
   asl
   asl
   asl                  ; A = I << 4
   sta VERA_data0       ; Set background color
   inx
   cpx mand_width
   bne @loop
   ldx #0
   iny
   cpy mand_height
   bne @loop
   clc
   jsr PLOT
   rts
