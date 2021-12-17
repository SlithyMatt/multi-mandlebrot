; FP Registers:
;  FP_A: HLB
;  FP_B: DEC
;  FP_R: (IX)

fp_remainder:
   dd 0

fp_i: ; loop index
   db 0

fp_scratch1:
   dd 0
fp_scratch2:
   dd 0

   MACRO FP_LDA_WORD source
      ld h,high source
      ld l,low source
      ld b,0
   ENDM

   MACRO FP_LDB_WORD source
      ld d,high source
      ld e,low source
      ld c,0
   ENDM

   MACRO FP_LDA_WORD_IND address
      ld b,0
      ld hl,(address)
   ENDM

   MACRO FP_LDB_WORD_IND address
      ld c,0
      ld de,(address)
   ENDM

   MACRO FP_LDA source
      ld b,low source
      ld hl,source >> 8
   ENDM

   MACRO FP_LDB source
      ld c,low source
      ld de,source >> 8
   ENDM

   MACRO FP_LDA_IND address
      ld a,(address)
      ld b,a
      ld hl,(address+1)
   ENDM

   MACRO FP_LDB_IND address
      ld a,(address)
      ld c,a
      ld de,(address+1)
   ENDM

   MACRO FP_STA dest
      ld a,b
      ld (dest),a
      ld (dest+1),hl
   ENDM

fp_floor: ; FP_A = floor(FP_A)
   bit 7,h
   jp z,.zerofrac
   ld a,0
   cp b
   ret z
   dec hl
.zerofrac:
   ld b,0
   ret

   MACRO FP_TAB ; FP_B = FP_A
      ld d,h
      ld e,l
      ld c,b
   ENDM

   MACRO FP_EXAB ; FP_A <-> FP_B
      ex de,hl
      ld a,b
      ld b,c
      ld c,a
   ENDM

   MACRO FP_SUBTRACT ; FP_A = FP_A - FP_B
      ld a,b
      sub c
      ld b,a
      sbc hl,de
   ENDM

   MACRO FP_ADD: ; FP_A = FP_A + FP_B
      ld a,b
      add c
      ld b,a
      adc hl,de
   ENDM

fp_divide: ; FP_A = FP_A / FP_B; FP_REM = FP_A % FP_B
   ld a,h
   ld (fp_scratch1+3),a  ; stash high byte of FP_A to test for sign later
   ld a,c
   ld (fp_scratch1),a
   ld (fp_scratch1+1),de ; preserve FP_B
   bit 7,h
   jp z,.check_sign_b
.abs_a:                 ; FP_A is negative, get |FP_A|
   FP_TAB
   FP_LDA_WORD 0
   FP_SUBTRACT          ; FP_A = |FP_A|
.check_sign_b:
   FP_LDB_IND fp_scratch1
   bit 7,d
   jp z,.shift_b
   FP_STA fp_scratch2   ; preserve FP_A
   FP_LDA_WORD 0
   FP_SUBTRACT          ; FP_A = |FP_B|
   FP_TAB               ; FP_B = |FP_B|
   FP_LDA_IND fp_scratch2  ; restore FP_A
.shift_b:
   ld c,e
   ld e,d
   ld d,0               ; FP_B = FP_B >> 8
   ld ix,fp_remainder
   ld (ix),d
   ld (ix+1),d
   ld (ix+2),d          ; FP_R = 0
   ld a,24              ;There are 24 bits in FP_A
   ld (fp_i),a
.loop1:
   sla b                ; Shift hi bit of FP_A into FP_R
   rl l
   rl h
   rl (ix)
   rl (ix+1)
   rl (ix+2)
   ld a,(ix)
   FP_STA fp_scratch2   ; trial subtraction
   FP_LDA_IND fp_remainder
   FP_SUBTRACT
   jp c,.loop2          ; Did subtraction succeed?
   FP_STA fp_remainder  ; if yes, save it
   ld a,(fp_scratch2)   ; and record a 1 in the quotient
   inc a
   ld (fp_scratch2),a
.loop2:
   FP_LDA_IND fp_scratch2
   ld a,(fp_i)          ; decrement index and loop while >0
   dec a
   ld (fp_i),a
   jp nz,.loop1
   FP_LDB_IND fp_scratch1   ; restore FP_B
   ld a,(fp_scratch1+3) ; get original high byte of FP_A
   bit 7,d
   jp nz,.check_cancel  ; if FP_B is negative, check for sign cancellation
   bit 7,a              ; FP_B is positive, check if original FP_A was negative
   ret z                ; Return if original FP_A was positive
   jp .negative         ; original FP_A was negative, reverse sign of new FP_A
.check_cancel:
   bit 7,a
   ret nz               ; if original FP_A was negative, signs cancel, so return
.negative:
   FP_TAB
   FP_LDA_WORD 0
   FP_SUBTRACT          ; FP_A = -FP_A
   FP_LDB_IND fp_scratch1   ; restore FP_B again
   ret

fp_multiply: ; slightly optimized version using hardware multiply
   ld a,h
   ld (fp_scratch2+2),a   ; store original FP_A sign
   bit 7,h
   jp z,.checkb
   ld a,0
   sub b
   ld b,a
   ld a,0
   sbc l
   ld l,a
   ld a,0
   sbc h
   ld h,a   ; FP_A = |FP_A|
.checkb:
   ld a,d
   ld (fp_scratch2+3),a   ; store original FP_B sign
   bit 7,d
   jp z,.save_de
   ld a,0
   sub c
   ld c,a
   ld a,0
   sbc e
   ld e,a
   ld a,0
   sbc d
   ld d,a   ; FP_B = |FP_B|
.save_de:
   ld (fp_scratch2),de
   ld d,c
   ld e,b
   mul d,e
   ld a,d
   ld (fp_scratch1),a
   ld d,l
   ld e,c
   mul d,e
   ld a,(fp_scratch1)
   add e
   ld (fp_scratch1),a
   ld a,0
   adc d
   ld d,h
   ld e,c
   mul d,e
   add e
   ld (fp_scratch1+1),a
   ld a,0
   adc d
   ld (fp_scratch1+2),a
   ld a,(fp_scratch2)
   ld e,a
   ld d,b
   mul d,e
   ld a,(fp_scratch1)
   add e
   ld (fp_scratch1),a
   ld a,(fp_scratch1+1)
   adc d
   ld (fp_scratch1+1),a
   ld a,(fp_scratch1+2)
   adc 0
   ld (fp_scratch1+2),a
   ld a,(fp_scratch2)
   ld e,a
   ld d,l
   mul d,e
   ld a,(fp_scratch1+1)
   add e
   ld (fp_scratch1+1),a
   ld a,(fp_scratch1+2)
   adc d
   ld (fp_scratch1+2),a
   ld a,(fp_scratch2)
   ld e,a
   ld d,h
   mul d,e
   ld a,(fp_scratch1+2)
   add e
   ld (fp_scratch1+2),a
   ld a,(fp_scratch2+1)
   ld e,a
   ld d,b
   mul d,e
   ld a,(fp_scratch1+1)
   add e
   ld (fp_scratch1+1),a
   ld a,(fp_scratch1+2)
   adc d
   ld (fp_scratch1+2),a
   ld a,(fp_scratch2+1)
   ld e,a
   ld d,l
   mul d,e
   ld a,(fp_scratch1+2)
   add e
   ld (fp_scratch1+2),a
   ld a,(fp_scratch1)
   ld b,a
   ld hl,(fp_scratch1+1)   ; FP_A = |FP_A| * |FP_B|
   ld a,(fp_scratch2+2)
   bit 7,a
   jp nz,.check_cancel
   ld a,(fp_scratch2+3)
   bit 7,a
   jp z,.restore_b
   jp .negative
.check_cancel:
   ld a,(fp_scratch2+3)
   bit 7,a
   jp nz,.restore_b
.negative:
   ld a,0
   sub b
   ld b,a
   ld a,0
   sbc l
   ld l,a
   ld a,0
   sbc h
   ld h,a
.restore_b:
   ld de,(fp_scratch2)
   ld a,(fp_scratch2+3)
   bit 7,a
   ret z
   ld a,0
   sub c
   ld c,a
   ld a,0
   sbc e
   ld e,a
   ld a,0
   sbc d
   ld d,a
   ret
