   DEVICE ZXSPECTRUM48

   org $8000

start:
   jp init

mand_width:    equ 32
mand_height:   equ 22
mand_max_it:   equ 15


   include "../Z80/mandelbrot.asm"

ROM_CLS           = $0DAF

COLOR_MAP         = $5800


i_result: db 0

color_codes:
   db 0,8,16,24,32,40,48,56
   db 72,80,88,96,104,112,120

init:
   exx                  ; save hl' register on stack
   push hl              ; to correct return into basic
   call ROM_CLS
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
   ld de,COLOR_MAP
   add hl,de            ; HL = COLOR_MAP+Y*32
   ld d,0
   ld e,b               ; DE = X
   add hl,de            ; HL = color attribute (x,y)
   ex de,hl
   ld hl,color_codes
   add a,l              ; DE = I
   ld l,a
   jp nc,.loopm1
   inc h
.loopm1:
   ;add ix,de            ; IX = &(color code for I)
   ld a,(hl)            ; A = color code for I
   ld (de),a            ; set color code
   inc b                ; increment X
   ld a,mand_width
   cp b
   jp nz,.loopm         ; loop until X = width
   ld b,0               ; X = 0
   inc c                ; increment Y
   ld a,mand_height
   cp c
   jp nz,.loopm         ; loop until Y = height
   pop hl               ; restore hl' register
   exx                  ; from stack
   ret


; Deployment
LENGTH      = $ - start

; option 1: tape
   include TapLib.asm
   MakeTape ZXSPECTRUM48, "man48.tap", "man48", start, LENGTH, start

; option 2: snapshot
   SAVESNA "man48.sna", start
