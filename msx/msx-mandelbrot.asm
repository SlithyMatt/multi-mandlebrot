CHGMOD:  equ $005F  ; BIOS change screen mode routine
T32NAM:  equ $F3BD  ; address in vram for character table
T32COL:  equ $F3BF  ; address in vram for color table
WRTVRM:  equ $004D  ; BIOS routine to write into vram

   OUTPUT "mand.bin"
   db $fe   ; binary file header
   dw start
   dw end
   dw init

   org $c000

start:
   jp init

   include "../Z80/mandelbrot.asm"

init:
   di
   ld a,1               ; screen mode 1 = 32x24 characters
   call CHGMOD          ; BIOS routine to set screen mode 
   ld a,$11             ; fill color table with values which have the same foreground and background color
   ld b,15              ; we use 15 such values starting from $11
   ld hl,(T32COL)       ; HL = start of color table, each byte describes color for 8 consecutive characters
   ld de,16             ; we use characters 128-255 so we need second half of color table
   add hl,de
.loopc:
   call WRTVRM          ; BIOS routine for write byte from A to address (HL) in vram
   add a,$11            ; increment foreground and background color 
   inc hl               ; next address in vram
   djnz .loopc

   ld bc,0              ; X = 0, Y = 0
.loopm:
   call mand_get
   ld h,0
   ld l,c               ; HL = Y
   add hl,hl
   add hl,hl
   add hl,hl
   add hl,hl
   add hl,hl            ; HL = Y*32
   ld de,(T32NAM)
   add hl,de            ; HL = (T32NAM)+Y*32
   ld d,0
   ld e,b               ; DE = X
   add hl,de            ; HL = color attribute (x,y)
   add a,a              ; convert color to character code
   add a,a              ; multiply by 8 as 8 consecutive characters have same color
   add a,a              
   add a,$80            ; add $80 to character code 
   call WRTVRM          ; write character to vram
   inc b                ; increment X
   ld a,MAND_WIDTH
   cp b
   jp nz,.loopm         ; loop until X = width
   ld b,0               ; X = 0
   inc c                ; increment Y
   ld a,MAND_HEIGHT
   cp c
   jp nz,.loopm         ; loop until Y = height
   ei
   ret

end:

