   DEVICE NOSLOT64K

   org $4000

start:
   jp init


   include "../Z80/mandelbrot.asm"

SCREEN_RAM              = $C000


i_result: db 0
screen_ptr: dw 0

color_codes:
   db $C0,$0C,$CC,$30,$F0,$3C,$FC
   db $03,$C3,$0F,$33,$F3,$3F,$FF,$00

init:
   ld bc,0              ; X = 0, Y = 0
.loopm:
   call mand_get
   ld ix,color_codes
   ld d,0
   ld e,a               ; DE = I
   add ix,de            ; IX = &(color code for I)
   ld h,0
   ld l,c               ; HL = Y
   sla l
   rl h
   sla l
   rl h
   sla l
   rl h
   sla l
   rl h                 ; HL = Y*16
   push hl
   pop de               ; DE = HL
   sla l
   rl h
   sla l
   rl h                 ; HL = Y*64
   add hl,de            ; HL = Y*80
   ld d,0
   ld e,b               ; DE = X
   sla e
   rl d                 ; DE = X*2
   add hl,de            ; HL = Y*80+X*2 (UL pixels of 4x8 square)
   ld d,4               ; column counter
   ld e,8               ; row counter
.loopp
   ld a,(ix)
   ld (hl),a
   inc hl
   dec d
   jp nz,.loopp
   push de
   ld de,$7FC
   add hl,de
   pop de
   ld d,4
   dec e
   jp nz,.loopp
   inc b                ; increment X
   ld a,MAND_WIDTH
   cp b
   jp nz,.loopm         ; loop until X = width
   ld b,0               ; X = 0
   inc c                ; increment Y
   ld a,MAND_HEIGHT
   cp c
   jp nz,.loopm         ; loop until Y = height
   ret


; Deployment
LENGTH      = $ - start

   SAVEBIN "man.bin",start,LENGTH
