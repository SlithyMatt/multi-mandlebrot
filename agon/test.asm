.assume adl=1
.org $040000

  jp start

; MOS header
  .align 64
  db "MOS",0,1

.include "ez80-fixedpt.asm"

opa:
  dw $EB80
  db 0

opb:
  dw $0400
  db 0

resc:
  dw 0
  db 0

start:
  push af
  push bc
  push de
  push ix
  push iy

  ld bc,0              ; zero out upper byte
  ld de,0              ; "
  ld hl,0              ; "
  exx
  ld bc,0              ; X = 0, Y = 0
  ld de,0              ; zero out upper byte
  ld hl,0              ; "
  ld ix,0              ; "
  ld iy,0              ; "

  FP_LDA_IND opa
  FP_LDB_IND opb

  call.l fp_multiply

  ld a,h
  call.l printhex
  ld a,l
  call.l printhex

  ld a,13
  rst.l $10
  ld a,10
  rst.l $10

  pop iy
  pop ix
  pop de
  pop bc
  pop af
  ld hl,0
  ret

printhex: ; print A as hex byte
  push af              ; save full byte on stack
  srl a
  srl a
  srl a
  srl a                ; move upper nybble to lower spot
  call.l printhex_digit  ; print upper nybble
  pop af               ; restore byte
  and $0F              ; clear out upper nybble
  call.l printhex_digit  ; print lower nybble
  ret.l

printhex_digit: ; print A as hex digit
  cp $0A
  jp p,print_letter
  or $30
  jp print_character
print_letter:
  add a,$37
print_character:
  rst.l $10
  ret.l
