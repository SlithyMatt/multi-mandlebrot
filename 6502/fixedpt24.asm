.ifndef FIXEDPT_INC
FIXEDPT_INC = 1

.macpack        cpu

.ifdef __CX16__
FP_A = $28
FP_B = $2B
FP_C = $2E
FP_R = $31
.endif

.ifdef __C64__
FP_A = $22
FP_B = $25
FP_C = $28
FP_R = $FB
.endif

fp_scratch: .res 3

.macro FP_LDA_WORD word_int
.if (.cpu .bitand ::CPU_ISET_65SC02)
   stz FP_A
.else
   lda #0
   sta FP_A
.endif
   lda word_int
   sta FP_A+1
   lda word_int+1
   sta FP_A+2
.endmacro


.macro FP_LDB_WORD word_int
.if (.cpu .bitand ::CPU_ISET_65SC02)
   stz FP_B
.else
   lda #0
   sta FP_B
.endif
   lda word_int
   sta FP_B+1
   lda word_int+1
   sta FP_B+2
.endmacro

.macro FP_LDA addr
   lda addr
   sta FP_A
   lda addr+1
   sta FP_A+1
   lda addr+2
   sta FP_A+2
.endmacro

.macro FP_LDB addr
   lda addr
   sta FP_B
   lda addr+1
   sta FP_B+1
   lda addr+2
   sta FP_B+2
.endmacro

.macro FP_LDA_IMM val
   lda #<val
   sta FP_A
   lda #>val
   sta FP_A+1
   lda #^val
   sta FP_A+2
.endmacro

.macro FP_LDB_IMM val
   lda #<val
   sta FP_B
   lda #>val
   sta FP_B+1
   lda #^val
   sta FP_B+2
.endmacro

.macro FP_LDA_IMM_INT val
.if (.cpu .bitand ::CPU_ISET_65SC02)
   stz FP_A
.else
   lda #0
   sta FP_A
.endif
   lda #<val
   sta FP_A+1
   lda #>val
   sta FP_A+2
.endmacro

.macro FP_LDB_IMM_INT val
.if (.cpu .bitand ::CPU_ISET_65SC02)
   stz FP_B
.else
   lda #0
   sta FP_B
.endif
   lda #<val
   sta FP_B+1
   lda #>val
   sta FP_B+2
.endmacro

.macro FP_STC addr
   lda FP_C
   sta addr
   lda FP_C+1
   sta addr+1
   lda FP_C+2
   sta addr+2
.endmacro

fp_floor: ; FP_C = floor(FP_C)
   bit FP_C+2
   bpl @zerofrac
   lda FP_C
   cmp #0
   beq @zerofrac
   lda FP_C+1
   sec
   sbc #1
   sta FP_C+1
   lda FP_C+2
   sbc #0
   sta FP_C+2
@zerofrac:
.if (.cpu .bitand ::CPU_ISET_65SC02)
   stz FP_C
.else
   lda #0
   sta FP_C
.endif
   rts

.macro FP_TCA ; FP_A = FP_C
   lda FP_C
   sta FP_A
   lda FP_C+1
   sta FP_A+1
   lda FP_C+2
   sta FP_A+2
.endmacro

.macro FP_TCB ; FP_B = FP_C
   lda FP_C
   sta FP_B
   lda FP_C+1
   sta FP_B+1
   lda FP_C+2
   sta FP_B+2
.endmacro

fp_subtract: ; FP_C = FP_A - FP_B
   lda FP_A
   sec
   sbc FP_B
   sta FP_C
   lda FP_A+1
   sbc FP_B+1
   sta FP_C+1
   lda FP_A+2
   sbc FP_B+2
   sta FP_C+2
   rts

fp_add: ; FP_C = FP_A + FP_B
   lda FP_A
   clc
   adc FP_B
   sta FP_C
   lda FP_A+1
   adc FP_B+1
   sta FP_C+1
   lda FP_A+2
   adc FP_B+2
   sta FP_C+2
   rts

fp_divide: ; FP_C = FP_A / FP_B; FP_R = FP_A % FP_B
.if (.cpu .bitand ::CPU_ISET_65SC02)
   phx
   phy
.else
   txa
   pha
   tya
   pha
.endif
   lda FP_B
   pha
   lda FP_B+1
   pha
   lda FP_B+2
   pha ; preserve original B on stack
   bit FP_A+2
   bmi @abs_a
   lda FP_A
   sta FP_C
   lda FP_A+1
   sta FP_C+1
   lda FP_A+2
   sta FP_C+2
.if (.cpu .bitand ::CPU_ISET_65SC02)
   bra @check_sign_b
.else
   jmp @check_sign_b
.endif
@abs_a:
   lda #0
   sec
   sbc FP_A
   sta FP_C
   lda #0
   sbc FP_A+1
   sta FP_C+1
   lda #0
   sbc FP_A+2
   sta FP_C+2 ; C = |A|
@check_sign_b:
   bit FP_B+1
   bpl @shift_b
   lda #0
   sec
   sbc FP_B
   sta FP_B
   lda #0
   sbc FP_B+1
   sta FP_B+1
   lda #0
   sbc FP_B+2
   sta FP_B+2
@shift_b:
   lda FP_B+1
   sta FP_B
   lda FP_B+2
   sta FP_B+1
   lda #0
   sta FP_B+2
.if (.cpu .bitand ::CPU_ISET_65SC02)
   stz FP_R
   stz FP_R+1
   stz FP_R+2
.else
   lda #0
   sta FP_R
   sta FP_R+1
   sta FP_R+2
.endif
   ldx #24     ;There are 24 bits in C
@loop1:
   asl FP_C    ;Shift hi bit of C into REM
   rol FP_C+1  ;(vacating the lo bit, which will be used for the quotient)
   rol FP_C+2
   rol FP_R
   rol FP_R+1
   rol FP_R+2
   lda FP_R
   sec         ;Trial subtraction
   sbc FP_B
   tay
   lda FP_R+1
   sbc FP_B+1
   sta fp_scratch
   lda FP_R+2
   sbc FP_B+2
   bcc @loop2  ;Did subtraction succeed?
   sta FP_R+2   ;If yes, save it
   lda fp_scratch
   sta FP_R+1
   sty FP_R
   inc FP_C    ;and record a 1 in the quotient
@loop2:
   dex
   bne @loop1
   pla
   sta FP_B+2
   pla
   sta FP_B+1
   pla
   sta FP_B
   bit FP_B+2
   bmi @check_cancel
   bit FP_A+2
   bmi @negative
   jmp @return
@check_cancel:
   bit FP_A+2
   bmi @return
@negative:
   lda #0
   sec
   sbc FP_C
   sta FP_C
   lda #0
   sbc FP_C+1
   sta FP_C+1
   lda #0
   sbc FP_C+2
   sta FP_C+2
@return:
.if (.cpu .bitand ::CPU_ISET_65SC02)
   ply
   plx
.else
   pla
   tay
   pla
   tax
.endif
   rts

fp_multiply: ; FP_C = FP_A * FP_B; FP_R overflow
.if (.cpu .bitand ::CPU_ISET_65SC02)
   phx
   phy
.else
   txa
   pha
   tya
   pha
.endif
   ; push original A and B to stack
   lda FP_A
   pha
   lda FP_A+1
   pha
   lda FP_A+2
   pha
   lda FP_B
   pha
   lda FP_B+1
   pha
   lda FP_B+2
   pha
   bit FP_A+2
   bpl @check_sign_b
   lda #0
   sec
   sbc FP_A
   sta FP_A
   lda #0
   sbc FP_A+1
   sta FP_A+1
   lda #0
   sbc FP_A+2
   sta FP_A+2 ; A = |A|
@check_sign_b:
   bit FP_B+2
   bpl @init_c
   lda #0
   sec
   sbc FP_B
   sta FP_B
   lda #0
   sbc FP_B+1
   sta FP_B+1
   lda #0
   sbc FP_B+2
   sta FP_B+2 ; B = |B|
@init_c:
   lda #0
   sta FP_R
   sta FP_R+1
   sta FP_R+2
   sta FP_C
   sta FP_C+1
   sta FP_C+2
   ldx #16
@loop1:
   lsr FP_B+2
   ror FP_B+1
   ror FP_B
   bcc @loop2
   clc
   lda FP_A
   adc FP_R
   sta FP_R
   lda FP_R+1
   adc FP_A+1
   sta FP_R+1
   lda FP_R+2
   adc FP_A+2
   sta FP_R+2
@loop2:
   ror FP_R+2
   ror FP_R+1
   ror FP_R
   ror FP_C+2
   ror FP_C+1
   ror FP_C
   dex
   bne @loop1
   ldx #8
@loop3:
   lsr FP_R+2
   ror FP_R+1
   ror FP_R
   ror FP_C+2
   ror FP_C+1
   ror FP_C
   dex
   bne @loop3
   ; restore A and B
   pla
   sta FP_B+2
   pla
   sta FP_B+1
   pla
   sta FP_B
   pla
   sta FP_A+2
   pla
   sta FP_A+1
   pla
   sta FP_A
   bit FP_B+2
   bmi @check_cancel
   bit FP_A+2
   bmi @negative
   jmp @return
@check_cancel:
   bit FP_A+2
   bmi @return
@negative:
   lda #0
   sec
   sbc FP_C
   sta FP_C
   lda #0
   sbc FP_C+1
   sta FP_C+1
   lda #0
   sbc FP_C+2
   sta FP_C+2
@return:
.if (.cpu .bitand ::CPU_ISET_65SC02)
   ply
   plx
.else
   pla
   tay
   pla
   tax
.endif
   rts

.endif
