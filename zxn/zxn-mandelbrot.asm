   DEVICE ZXSPECTRUMNEXT

   org $8000

start:
   jp init

   include "../Z80n/mandelbrot.asm"

SCREEN_PIXELS     = $4000
COLOR_MAP         = $5800


i_result: db 0

color_codes:
   db 8,16,24,32,40,48,56,72
   db 80,88,96,104,112,120,0

init:
   nextreg $07,$03      ; set to 28 MHz
   exx                  ; save hl' register on stack
   push hl              ; to correct return into basic
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
   ld a,(hl)            ; A = color code for I
   ld (de),a            ; set color code
   inc b                ; increment X
   ld a,MAND_WIDTH
   cp b
   jp nz,.loopm         ; loop until X = width
   ld b,0               ; X = 0
   inc c                ; increment Y
   ld a,MAND_HEIGHT
   cp c
   jp nz,.loopm         ; loop until Y = height
   pop hl               ; restore hl' register
   exx                  ; from stack
.loop_end:
   jp .loop_end
   ret


; Deployment
LENGTH      = $ - start

;;; option 3: nex
   SAVENEX OPEN "man.nex",start
   SAVENEX AUTO
   SAVENEX CLOSE
