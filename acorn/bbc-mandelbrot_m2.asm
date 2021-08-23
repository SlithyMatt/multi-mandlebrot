.org $1900
.segment "STARTUP"
.segment "INIT"
.segment "ONCE"
.segment "CODE"

   jmp start

.include "../6502/mandelbrot.asm"

ZP_PTR            = $50
ZP_SCRATCH        = $52

SCREEN_MODE       = $0355
SCREEN_MAP        = $3000

i_result: .byte 0

color_codes:
   .byte $3F,$03,$0C,$0F   ; white, red, green, yellow
   .byte $30,$33,$3C       ; blue, magenta, cyan
   .byte $3F,$03,$0C,$0F   ; white, red, green, yellow
   .byte $30,$33,$3C,$00   ; blue, magenta, cyan, black

start:
   lda #2
   sta SCREEN_MODE
   ; clear screen?
   ldx #0
   ldy #0
@loop:
   lda mand_max_it
   jsr mand_get
   sta i_result
   txa
   pha ; preserve X
   tya
   pha ; preserve Y
   lda #<SCREEN_MAP
   sta ZP_PTR
   lda #>SCREEN_MAP
   sta ZP_PTR+1
   tya
   sta ZP_SCRATCH
   lda #0
   sta ZP_SCRATCH+1
   asl ZP_SCRATCH
   rol ZP_SCRATCH+1
   asl ZP_SCRATCH
   rol ZP_SCRATCH+1
   asl ZP_SCRATCH
   rol ZP_SCRATCH+1
   asl ZP_SCRATCH
   rol ZP_SCRATCH+1
   asl ZP_SCRATCH
   rol ZP_SCRATCH+1
   asl ZP_SCRATCH
   rol ZP_SCRATCH+1
   asl ZP_SCRATCH
   rol ZP_SCRATCH+1
   lda ZP_PTR
   clc
   adc ZP_SCRATCH
   sta ZP_PTR
   lda ZP_PTR+1
   adc ZP_SCRATCH+1
   sta ZP_PTR+1      ; ZP_PTR = SCREEN_MAP+Y*$80
   asl ZP_SCRATCH
   rol ZP_SCRATCH+1
   asl ZP_SCRATCH
   rol ZP_SCRATCH+1
   lda ZP_PTR
   clc
   adc ZP_SCRATCH
   sta ZP_PTR
   lda ZP_PTR+1
   adc ZP_SCRATCH+1
   sta ZP_PTR+1      ; ZP_PTR = SCREEN_MAP+Y*$280
   txa
   sta ZP_SCRATCH
   lda #0
   sta ZP_SCRATCH+1
   asl ZP_SCRATCH
   rol ZP_SCRATCH+1
   asl ZP_SCRATCH
   rol ZP_SCRATCH+1
   asl ZP_SCRATCH
   rol ZP_SCRATCH+1
   asl ZP_SCRATCH
   rol ZP_SCRATCH+1
   lda ZP_PTR
   clc
   adc ZP_SCRATCH
   sta ZP_PTR
   lda ZP_PTR+1
   adc ZP_SCRATCH+1
   sta ZP_PTR+1      ; ZP_PTR = SCREEN_MAP+Y*$280+X*$10
   ldx i_result
   lda color_codes,x
   ldy #16
@pix_loop:
   sta (ZP_PTR),y
   dey
   bne @pix_loop
   pla
   tay ; restore Y
   pla
   tax ; restore X
   inx
   cpx mand_width
   bne @loop
   ldx #0
   iny
   cpy mand_height
   bne @loop
   ; place READY prompt?
   rts
