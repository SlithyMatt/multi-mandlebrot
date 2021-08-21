.org $080D
.segment "STARTUP"
.segment "INIT"
.segment "ONCE"
.segment "CODE"

   jmp start

.include "../6502/mandelbrot.asm"

CLEAR_SCREEN      = $93
REVERSE_SPACE     = $A0

SCREEN_MAP        = $0400
COLOR_MAP         = $D800

CHROUT            = $FFD2
PLOT              = $FFF0

i_result: .byte 0

start:
   lda #CLEAR_SCREEN
   jsr CHROUT
   ldx #0
   ldy #0
@loop:
   jsr mand_get
   sta i_result
   sty FP_A
   lda #0
   sta FP_A+1
   asl FP_A
   rol FP_A+1
   asl FP_A
   rol FP_A+1
   asl FP_A
   rol FP_A+1
   lda FP_A+1
   sta FP_B+1
   lda FP_A
   sta FP_B ; FP_B = Y*8
   asl FP_A
   rol FP_A+1
   asl FP_A
   rol FP_A+1 ; FP_A = Y*32
   clc
   adc FP_A
   sta FP_A
   lda FP_A+1
   adc FP_B+1
   sta FP_A+1 ; FP_A = Y*40
   lda FP_A
   txa
   adc FP_A
   sta FP_A
   sta FP_B
   lda FP_A+1
   adc #0
   sta FP_A+1 ; FP_A = Y*40+X
   sta FP_B+1  ; FP_B = Y*40+X
   lda FP_A
   adc #<SCREEN_MAP
   sta FP_A
   lda FP_A+1
   adc #>SCREEN_MAP
   sta FP_A+1
   txa
   pha ; preserve X
   ldx #0
   lda #REVERSE_SPACE
   sta (FP_A,x)         ; place reverse space character code
   lda FP_B
   adc #<COLOR_MAP
   sta FP_B
   lda FP_B+1
   adc #>COLOR_MAP
   sta FP_B+1
   lda i_result
   sta (FP_B,x)         ; set color index
   pla
   tax ; restore X
   inx
   cpx mand_width
   bne @loop
   ldx #0
   iny
   cpy mand_height
   bne @loop
   clc
   tya
   tax
   ldy #0
   jsr PLOT
   rts
