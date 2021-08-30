; FP Registers:
;  FP_A: BC
;  FP_B: DE
;  FP_C: HL
;  FP_R: (IX)

fp_remainder:
   dw 0

fp_i: ; loop index
   db 0

fp_scratch:
   dw 0

   MACRO FP_LDA_BYTE source
      ld b,source
      ld c,0
   ENDM

   MACRO FP_LDB_BYTE source
      ld d,source
      ld e,0
   ENDM

   MACRO FP_LDA_BYTE_IND address
      ld a,(address)
      ld b,a
      ld c,0
   ENDM

   MACRO FP_LDB_BYTE_IND address
      ld a,(address)
      ld d,a
      ld e,0
   ENDM

   MACRO FP_LDA source
      ld bc,source
   ENDM

   MACRO FP_LDB source
      ld de,source
   ENDM

   MACRO FP_LDA_IND address
      ld bc,(address)
   ENDM

   MACRO FP_LDB_IND address
      ld de,(address)
   ENDM

   MACRO FP_STC dest
      ld (dest),hl
   ENDM

fp_multiply: ; simple, not fast
  call smult32
  ld a,h
  ld (fp_remainder),a
  ld h,l
  xor a
  ld (fp_remainder+1),a
  exx
  ld a,h
  exx
  ld l,a
  ret

smult32: ; signed get bc*de in hl and hl'
  bit 7,b
  jp z,.part2
  sub hl,de
.part2:
  bit 7,d
  ret z
  sub hl,bc
  ret

umult32: ; unsigned get bc*de in hl and hl'
  push de
  ld (fp_scratch),de
  ld d,c
  mul d,e ; c*e
  ld a,e
  ld l,d
  ld h,$00
  exx
  ld l,a
  ld h,$00
  exx
  ld a,(fp_scratch)
  ld e,a
  ld d,b
  mul d,e ; b*e
  add hl,de ; can't overflow
  ld a,(fp_scratch+1)
  ld e,a
  ld d,c
  mul d,e ; c*d
  add hl,de
  ld a,l
  ld l,h
  exx
  ld h,a
  exx
  ld a,$00
  adc a,$00
  ld h,a
  ld a,(fp_scratch+1)
  ld e,a
  ld d,b
  mul d,e ; c*d
  add hl,de
  pop de
  ret
