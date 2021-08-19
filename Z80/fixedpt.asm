MACRO FP_LDA_BYTE source
   ld b,source
   ld c,0
ENDM

MACRO FP_LDB_BYTE source
   ld d,source
   ld e,0
ENDM

MACRO FP_LDA source
   ld bc,source
ENDM

MACRO FP_LDB source
   ld de,source
ENDM

MACRO FP_STC dest
   ld dest,hl
ENDM

fp_floor_byte: ; A = floor(FP_C)
   ld a,h
   bit 7,a
   ret z
   ld a,0
   cp l
   ld a,h
   ret z
   dec a
   ret

fp_floor: ; FP_C = floor(FP_C)
   bit 7,h
   jp z,.zerofrac
   ld a,0
   cp l
   jp z, .zerofrac
   dec h
.zerofrac:
   ld l,0
   ret

MACRO FP_TCA ; FP_A = FP_C
   ld b,h
   ld c,l
ENDM

MACRO FP_TCB ; FP_B = FP_C
   ld d,h
   ld e,l
ENDM

MACRO FP_SUBTRACT ; FP_C = FP_A - FP_B
   ld h,b
   ld l,c
   or a
   sbc hl,de
ENDM

MACRO FP_ADD: ; FP_C = FP_A + FP_B
   ld h,b
   ld l,c
   add hl,de
ENDM

fp_divide: ; FP_C = FP_A / FP_B; FP_R = FP_A % FP_B
   
