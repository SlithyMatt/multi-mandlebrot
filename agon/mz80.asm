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

  ld a,$04
  ld mb,a
  call.lis plot

  ld a,0
  rst.lil $08 ; wait for key press

  ld a,17 ; set color
  rst.lil $10
  ld a,15 ; white
  rst.lil $10
  ld a,22 ; set mode
  rst.lil $10
  ld a,1  ; mode 1: 512x384x16
  rst.lil $10
  ld a,12 ; CLS
  rst.lil $10


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

end_ez80:

START_Z80: equ $041000

.blkb START_Z80-end_ez80,0

.org $041000

plot:
.incbin "agon-z80-mandelbrot.bin"
