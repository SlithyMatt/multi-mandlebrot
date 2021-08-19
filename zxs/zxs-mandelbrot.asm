   DEVICE ZXSPECTRUM48

   org $8000

start:
   jp init


   include "../z80/mandelbrot.asm"

COLOR_MAP         = $5800


i_result: db 0

color_codes:
   db 0,8,16,24,32,40,48,56
   db 72,80,88,96,104,112,120

init:
   lda #CLEAR_SCREEN
   jsr CHROUT
   lda #REVERSE_ON
   jsr CHROUT
   ldx #0
   ldy #0
@loop:
   lda mand_max_it
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
   cpx mand_width
   bne @loop
   lda #RETURN
   jsr CHROUT
   lda #REVERSE_ON
   jsr CHROUT
   ldx #0
   iny
   cpy mand_height
   bne @loop
   lda #$9A ; restore lt blue text
   jsr CHROUT
   rts


; Deployment
LENGTH      = $ - start

; option 1: tape
   include TapLib.asm
   MakeTape ZXSPECTRUM48, "pop.tap", "pop", start, LENGTH, start

; option 2: snapshot
   SAVESNA "pop.sna", start
