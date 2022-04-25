!to "mathtest.prg", cbm
!cpu m65

!source "mega65defs.asm"

        * = $2100

start:
        lda #0
        ldx #0
        ldy #0
        ldz #%10110000
        map                     ; set memory map to give us IO and some ROM (right?)
        eom
        sei
        lda fp_a
        sta MATH_IN_A
        lda fp_a+1
        sta MATH_IN_A+1
        lda fp_a+2
        sta MATH_IN_A+2
        lda fp_a+3
        sta MATH_IN_A+3
        lda fp_b
        sta MATH_IN_B
        lda fp_b+1
        sta MATH_IN_B+1
        lda fp_b+2
        sta MATH_IN_B+2
        lda fp_b+3
        sta MATH_IN_B+3
        ;
        lda MATH_MULTOUT
        sta res_mul
        lda MATH_MULTOUT+1
        sta res_mul+1
        lda MATH_MULTOUT+2
        sta res_mul+2
        lda MATH_MULTOUT+3
        sta res_mul+3
        lda MATH_MULTOUT+4
        sta res_mul+4
        lda MATH_MULTOUT+5
        sta res_mul+5
        lda MATH_MULTOUT+6
        sta res_mul+6
        lda MATH_MULTOUT+7
        sta res_mul+7
        lda MATH_DIVOUT
        ;
        sta res_div
        lda MATH_DIVOUT+1
        sta res_div+1
        lda MATH_DIVOUT+2
        sta res_div+2
        lda MATH_DIVOUT+3
        sta res_div+3
        lda MATH_DIVOUT+4
        sta res_div+4
        lda MATH_DIVOUT+5
        sta res_div+5
        lda MATH_DIVOUT+6
        sta res_div+6
        lda MATH_DIVOUT+7
        sta res_div+7
        cli
        rts

fp_a:    !byte $1, $0, $0, $0
fp_b:    !byte $2, $0, $0, $0
res_mul: !word $0, $0, $0, $0
res_div: !word $0, $0, $0, $0
