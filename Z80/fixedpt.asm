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

fp_floor_byte: ; A = floor(FP_C)
   ld a,h
   or a
   ret p
   ld a,l
   or a
   ld a,h
   ret z
   dec a
   ret

fp_floor: ; FP_C = floor(FP_C)
   xor a
   bit 7,h
   jp z,.zerofrac
   cp l
   jp z, .zerofrac
   dec h
.zerofrac:
   ld l,a
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

   MACRO FP_ADD ; FP_C = FP_A + FP_B
      ld h,b
      ld l,c
      add hl,de
   ENDM

fp_divide: ; FP_C = FP_A / FP_B; FP_REM = FP_A % FP_B
   push de              ; preserve FP_B
   bit 7,b
   jp nz,.abs_a         ; get |FP_A| if negative
   ld h,b
   ld l,c               ; FP_C = FP_A
   jp .check_sign_b
.abs_a:
   ld hl,0
   or a
   sbc hl,bc            ; FP_C = |FP_A|
.check_sign_b:
   bit 7,d
   jp z,.shift_b
   push hl              ; preserve FP_C
   ld hl,0
   or a
   sbc hl,de
   ex de,hl             ; FP_B = |FP_B|
   pop hl               ; restore FP_C
.shift_b:
   ld e,d
   ld d,0
   push bc              ; preserve FP_A
   ld bc,0
   push bc
   ld b,16
.loop1:
   add hl,hl                ; Shift hi bit of FP_C into REM
   ex  (sp),hl
   adc hl,hl
   ld a,l
   sub e                ; trial subtraction
   ld c,a
   ld a,h
   sbc a,d
   jp c,.loop2          ; Did subtraction succeed?
   ld l,c            ; if yes, save it
   ld h,a
   ex (sp),hl
   inc l                ; and record a 1 in the quotient
   jp .loop3
.loop2:
   ex (sp),hl
.loop3
   dec b
   jp nz,.loop1
   pop de
   pop bc               ; restore FP_A
   pop de               ; restore FP_B
   bit 7,d
   jp nz,.check_cancel
   bit 7,b
   ret z
   jp .negative
.check_cancel:
   bit 7,b
   ret nz
.negative:
   push bc
   ld b,h
   ld c,l
   ld hl,0
   or a
   sbc hl,bc
   pop bc
   ret

fp_multiply ; FP_C = FP_A * FP_B; FP_R overflow
   push bc              ; preserve FP_A
   push de              ; preserve FP_B
   bit 7,b
   jp z,.check_sign_b
   ld hl,0
   or a
   sbc hl,bc
   FP_TCA               ; FP_A = |FP_A|
.check_sign_b:
   bit 7,d
   jp z,.init_c
   ld hl,0
   or a
   sbc hl,de
   FP_TCB               ; FP_B = |FP_B|
.init_c:
   ld ixl,0
   xor a
   ld h,a
   ld l,a
   exx 
   ld h,a
   ld l,a
   ld d,a
   ld e,a
   exx
   ex af,af'
   ld a,16
.loop1:
   ex af,af'
   srl d
   rr e
   push bc
   exx
   pop bc
   jp nc,.loop2
   add hl,bc
.loop2:
   rr h
   rr l
   exx
   rr h
   rr l
   ex af,af'
   dec a
   jp nz,.loop1
   exx
   ld h,a
   ld b,8
.loop3:
   srl h
   rr l
   exx
   rr h
   rr l
   exx
   djnz .loop3
   exx
   pop de            ; restore FP_B
   pop bc            ; restore FP_A
   bit 7,d
   jp nz,.check_cancel
   bit 7,b
   ret z
   jp .negative
.check_cancel:
   bit 7,b
   ret nz
.negative:
   push bc           ; preserve FP_A
   ld b,h
   ld c,l
   ld hl,0
   or a
   sbc hl,bc
   pop bc            ; restore FP_A
   ret
