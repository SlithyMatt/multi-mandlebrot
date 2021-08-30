  DEVICE ZXSPECTRUMNEXT

  org $8000

start:
  call stiple
  ld bc,$0101
  ld de,$0101
  push bc
  push de
  call fp_mult
  push bc
  push de
  push hl
  exx
  push hl
  exx
  pop de
  ld b,8
  ld hl,$4000
  call .draw
  pop de
  ld b,8
  ld hl,$4002
  call .draw
  pop de
  ld b,8
  ld hl,$4006
  call .draw
  pop de
  ld b,8
  ld hl,$400a
  call .draw
  pop de
  pop bc
  call fp_multiply
  ld de,hl
  ld b,8
  ld hl,$4022
  call .draw
.loop:
  jp .loop
.draw:
  ld (hl),de
  inc h
  djnz .draw
  ret

  include "../Z80n/fixedpt.asm"
  include "stiple.asm"

  SAVENEX OPEN "test.nex",start
  SAVENEX AUTO
  SAVENEX CLOSE
