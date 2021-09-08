!ifndef FIXEDPTDEFS_INC {
FIXEDPTDEFS_INC = 1

!address {
FP_A  = $00
FP_B  = $02
FP_C  = $04
FP_R  = $08
}

!macro FP_LDA .addr {
        lda .addr
        sta FP_A
        lda .addr+1
        sta FP_A+1
}

!macro FP_LDB .addr {
        lda .addr
        sta FP_B
        lda .addr+1
        sta FP_B+1
}

!macro FP_LDA_IMM .val {
        lda #<.val
        sta FP_A
        lda #>.val
        sta FP_A+1
}

!macro FP_LDB_IMM .val {
        lda #<.val
        sta FP_B
        lda #>.val
        sta FP_B+1
}

!macro FP_LDA_IMM_INT .val {
        stz FP_A
        lda #.val
        sta FP_A+1
}

!macro FP_LDB_IMM_INT .val {
        stz FP_B
        lda #.val
        sta FP_B+1
}

!macro FP_STC .addr {
        lda FP_C
        sta .addr
        lda FP_C+1
        sta .addr+1
}

!macro FP_TCA { ; FP_A = FP_C
        lda FP_C
        sta FP_A
        lda FP_C+1
        sta FP_A+1
}

!macro FP_TCB { ; FP_B = FP_C
        lda FP_C
        sta FP_B
        lda FP_C+1
        sta FP_B+1
}

!macro FP_LDA_BYTE { ; FP_A = A
        sta FP_A+1
        stz FP_A
}

!macro FP_LDB_BYTE { ; FP_B = A
        sta FP_B+1
        stz FP_B
}

}
