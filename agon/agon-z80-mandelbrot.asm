.assume adl=1
.org $040000

  jp start

; MOS header
  .align 64
  db "MOS",0,1

start:
  push af
  push bc
  push de
  push ix
  push iy

  ld hl,vdu_setup
  ld bc,end_vdu_setup-vdu_setup
  rst.lil $18

  call.is plot

  pop iy
  pop ix
  pop de
  pop bc
  pop af
  ld hl,0

  ret

vdu_setup:
  db 22,2        ; mode 2
  db 23,255,255,255,255,255,255,255,255,255 ; char 255 = solid block
end_vdu_setup:

;.assume adl=0
.include "z80-mandelbrot.asm"

plot:
   ld bc,0              ; X = 0, Y = 0
plot_loop:
   call mand_get
   ld e,a               ; e = num iterations
   ld a,17              ; set color
   rst $10
   ld a,e
   rst $10              ; color index = number of iterations
   ld a,255
   rst $10              ; print solid block
   inc b                ; increment X
   ld a,MAND_WIDTH
   cp b
   jp nz,plot_loop      ; loop until X = width
   ld b,0               ; X = 0
   inc c                ; increment Y
   ld a,MAND_HEIGHT
   cp c
   jp nz,plot_loop      ; loop until Y = height
   ret
