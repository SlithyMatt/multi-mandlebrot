.include "ppu.inc"
.include "apu.inc"

.include "neshdr.asm"
.include "neschar.asm"

.segment "STARTUP"
.segment "CODE"

   jmp start

.include "../6502/mandelbrot.asm"

PLOTADDR       = $16

DEFMASK        = %00001000 ; background enabled

.macro WAIT_VBLANK
:  bit PPUSTATUS
   bpl :-
.endmacro

start:
   sei
   cld
   ldx #$40
   stx APU_FRAMECTR ; disable IRQ
   ldx #$FF
   txs ; init stack pointer
   inx ; reset X to zero to initialize PPU and APU registers
   stx PPUCTRL
   stx PPUMASK
   stx APU_MODCTRL

   WAIT_VBLANK

   ; while waiting for two frames for PPU to stabilize, reset RAM
   txa   ; still zero!
@clr_ram:
   sta $000,x
   sta $100,x
   sta $200,x
   sta $300,x
   sta $400,x
   sta $500,x
   sta $600,x
   sta $700,x
   inx
   bne @clr_ram

   WAIT_VBLANK

   ; start writing to palette, starting with background color
   lda #>BG_COLOR
   sta PPUADDR
   lda #<BG_COLOR
   sta PPUADDR
   lda #BLACK
   sta PPUDATA ; black backround color
   lda #(RED | NEUTRAL)
   sta PPUDATA ; background palette 0, color 1 = red
   lda #(GREEN | NEUTRAL)
   sta PPUDATA ; color 2 = green
   lda #(BLUE| NEUTRAL)
   sta PPUDATA ; color 3 = blue

@setpal:
   ; set all attribute A tiles to palette 0
   lda #>ATTRTABLE_A
   sta PPUADDR
   lda #<ATTRTABLE_A
   sta PPUADDR
   ldx #64
   lda #0
@attr_loop:
   sta PPUDATA
   dex
   bne @attr_loop

   ; enable display
   lda #DEFMASK
   sta PPUMASK

   lda #<NAMETABLE_A
   sta PLOTADDR
   lda #>NAMETABLE_A
   sta PLOTADDR+1
   ldx #0
   ldy #0
@plot_loop:
   jsr mand_get
   clc
   adc #1
   cmp #15
   bne @plot
   lda #0
@plot:
   pha
   WAIT_VBLANK
   lda PLOTADDR+1
   sta PPUADDR
   lda PLOTADDR
   sta PPUADDR
   pla
   sta PPUDATA
   lda PLOTADDR
   clc
   adc #1
   sta PLOTADDR
   lda PLOTADDR+1
   adc #0
   sta PLOTADDR+1
   inx
   cpx #MAND_WIDTH
   bne @plot_loop
   ldx #0
   iny
   cpy #MAND_HEIGHT
   bne @plot_loop

   ; set scroll position to 0,0
   lda #0
   sta PPUSCROLL ; x = 0
   sta PPUSCROLL ; y = 0

@game_loop:
   WAIT_VBLANK
   ; do something
   jmp @game_loop


; ------------------------------------------------------------------------
; System V-Blank Interrupt
; ------------------------------------------------------------------------

nmi:
   pha

   ; refresh scroll position to 0,0
   lda #0
   sta PPUSCROLL
   sta PPUSCROLL

   ; keep default PPU config
   sta PPUCTRL
   lda #DEFMASK
   sta PPUMASK

   pla

   ; Interrupt exit
irq:
   rti


.segment "VECTORS"
.word   nmi         ; $fffa vblank nmi
.word   start       ; $fffc reset
.word   irq         ; $fffe irq / brk
