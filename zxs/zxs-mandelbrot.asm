   DEVICE ZXSPECTRUM48

   org $8000

start:
   jp init


   include "../Z80/mandelbrot.asm"

COLOR_MAP         = $5800


i_result: db 0

color_codes:
   db 0,8,16,24,32,40,48,56
   db 72,80,88,96,104,112,120

init:
   ld bc,0              ; X = 0, Y = 0
.loopm:
   call mand_get
   ld h,0
   ld l,c               ; HL = Y
   sla l
   rl h
   sla l
   rl h
   sla l
   rl h
   sla l
   rl h
   sla l
   rl h                 ; HL = Y*32
   ld de,COLOR_MAP
   add hl,de            ; HL = COLOR_MAP+Y*32
   ld d,0
   ld e,b               ; DE = X
   add hl,de            ; HL = color attribute (x,y)
   ld ix,color_codes
   ld e,a               ; DE = I
   add ix,de            ; IX = &(color code for I)
   ld a,(ix)            ; A = color code for I
   ld (hl),a            ; set color code
   inc b                ; increment X
   ld a,(mand_width)
   cp b
   jp nz,.loopm         ; loop until X = width
   ld b,0               ; X = 0
   inc c                ; increment Y
   ld a,(mand_height)
   cp c
   jp nz,.loopm         ; loop until Y = height
   ret


; Deployment
LENGTH      = $ - start

; option 1: tape
   include TapLib.asm
   MakeTape ZXSPECTRUM48, "man48.tap", "man48", start, LENGTH, start

; option 2: snapshot
   SAVESNA "man48.sna", start
