.org $080D
.segment "STARTUP"
.segment "INIT"
.segment "ONCE"
.segment "CODE"

   jmp start

.include "../6502/mandelbrot.asm"

RETURN            = $0D
REVERSE_ON        = $12
SPACE             = $20
REVERSE_OFF       = $92
CLEAR_SCREEN      = $93

SCREEN_MAP        = $0400
COLOR_MAP         = $D800

CHROUT            = $FFD2
PLOT              = $FFF0

i_result: .byte 0

color_codes:
   .byte $05, $1C, $1E, $1F   ; white, red, green, blue
   .byte $81, $96, $95, $97   ; orange, lt red, brown, dk gray
   .byte $98, $99, $9A, $9B   ; md gray, lt green, lt blue, lt gray
   .byte $9C, $9E, $90        ; purple, yellow, black

start:
   sei
   lda #CLEAR_SCREEN
   jsr CHROUT
   lda #REVERSE_ON
   jsr CHROUT
   ldx #0
   ldy #0
@loop:
   jsr mand_get
   sta i_result
   txa
   pha ; preserve X
   ldx i_result
   lda color_codes,x
   jsr CHROUT
   lda #SPACE
   jsr CHROUT
   pla
   tax ; restore X
   inx
   cpx #MAND_WIDTH
   bne @loop
   lda #RETURN
   jsr CHROUT
   lda #REVERSE_ON
   jsr CHROUT
   ldx #0
   iny
   cpy #MAND_HEIGHT
   bne @loop
   lda #$9A ; restore lt blue text
   jsr CHROUT
   cli
   rts
