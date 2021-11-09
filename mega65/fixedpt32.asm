fp_x_sr:
        rts

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
        lda FP_A+3
        sbc FP_B+3
        sta FP_C+3
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
        lda FP_A+3
        adc FP_B+3
        sta FP_C+3
        rts

fp_multiply:    ; FP_C = FP_A * FP_A
        +FP_ABS FP_A, FP_C
        +FP_MOV FP_C, MATH_IN_A
        +FP_ABS FP_B, FP_C
        +FP_MOV FP_C, MATH_IN_B
        +FP_MOV MATH_MULTOUT+3, FP_C ; 64 bit result, shifted 3 byte
        bit FP_A+3
        bmi +
        bit FP_B+3
        bmi ++
        bra +++
+       bit FP_B+3
        bmi ++
        bra +++
++      +FP_ABS FP_C, FP_C
+++     rts

; special, because we do not need to care about the sign for the result
fp_square:      ; FP_C = FP_A * FP_A
        bit FP_A+3
        bpl @sq_pl
        lda #0
        sec
        sbc FP_A
        sta MATH_IN_A
        sta MATH_IN_B
        lda #0
        sbc FP_A+1
        sta MATH_IN_A+1
        sta MATH_IN_B+1
        lda #0
        sbc FP_A+2
        sta MATH_IN_A+2
        sta MATH_IN_B+2
        lda #0
        sbc FP_A+3
        sta MATH_IN_A+3
        sta MATH_IN_B+3
        bra @sq_res
@sq_pl:
        +FP_DMOV FP_A, MATH_IN_A, MATH_IN_B
@sq_res:
        +FP_MOV MATH_MULTOUT+3, FP_C     ; 64 bit result, 16.48
        rts

fp_divide:      ; FP_C = FP_A / FP_B
        ; sign?
        +FP_MOV FP_A, MATH_IN_A
        +FP_MOV FP_B, MATH_IN_B
        ; delay until result is ready (16 cycles)
        lda MATH_DIVOUT
        lda MATH_DIVOUT
        lda MATH_DIVOUT
        +FP_MOV MATH_DIVOUT+1, FP_C ; 64 bit result, 32.32?
        rts
