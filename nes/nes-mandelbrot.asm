.include "ppu.inc"
.include "apu.inc"

.include "neshdr.asm"
.include "neschar.asm"

.segment "STARTUP"
.segment "CODE"

   jmp start



hello_str: .asciiz "Hello, World!"

DEFMASK        = %00001000 ; background enabled

START_X        = 9
START_Y        = 14
START_NT_ADDR  = NAMETABLE_A + 32*START_Y + START_X
START_AT_ADDR  = ATTRTABLE_A + 32*START_Y + START_X

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
   lda #BLACK
   sta PPUDATA ; black backround color
   lda #(MAGENTA | LIGHT)
   sta PPUDATA ; background palette 1, color 1 = light magenta
   lda #(GREEN | NEUTRAL)
   sta PPUDATA ; color 2 = green
   lda #(BLUE | DARK)
   sta PPUDATA ; color 3 = dark blue
   lda #BLACK
   sta PPUDATA ; black backround color
   lda #(YELLOW | LIGHT)
   sta PPUDATA ; background palette 2, color 1 = light yellow
   lda #(ORANGE | LIGHT)
   sta PPUDATA ; color 2 = orange
   lda #(ORANGE | DARK)
   sta PPUDATA ; color 3 = brown
   lda #BLACK
   sta PPUDATA ; black backround color
   lda #(SALMON | NEUTRAL)
   sta PPUDATA ; background palette 3, color 1 = salmon
   lda #(GRAY | DARK)
   sta PPUDATA ; color 2 = dark gray
   lda #(GRAY | NEUTRAL)
   sta PPUDATA ; color 3 = medium gray
   lda #BLACK
   sta PPUDATA ; black backround color
   lda #(GREEN | VERY_LIGHT)
   sta PPUDATA ; sprite palette 0, color 1 = light green
   lda #(BLUE | LIGHT)
   sta PPUDATA ; color 2 = light blue
   lda #(GRAY | LIGHT)
   sta PPUDATA ; color 3 = light gray (actually white, but won't be used)



   ; place string character tiles
   lda #>START_NT_ADDR
   sta PPUADDR
   lda #<START_NT_ADDR
   sta PPUADDR
   ldx #0
@string_loop:
   lda hello_str,x
   beq @setpal
   sta PPUDATA
   inx
   jmp @string_loop

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

   ; set scroll position to 0,0
   lda #0
   sta PPUSCROLL ; x = 0
   sta PPUSCROLL ; y = 0
   ; enable display
   lda #DEFMASK
   sta PPUMASK

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
