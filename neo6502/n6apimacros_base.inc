.ifndef NEO6502_ASM_INC
.include "neo6502.asm.inc"
.endif

N6API_MACROS_BASE_INC = 1

;--------------------------------------;
; Neo6502 Kernel API macros          ;
;--------------------------------------;

; Zero page (for all API calls)
MATH_API_ZP_BASE_PTR = $FE
MATH_API_ZP_STRIDE = $FD

API_SOURCE_PTR = $FB

MATH_API_REG_1_VAL_BYTE_3_OFFSET = $FA
MATH_API_REG_1_VAL_BYTE_2_OFFSET = $F9
MATH_API_REG_1_VAL_BYTE_1_OFFSET = $F8
MATH_API_REG_1_VAL_BYTE_0_OFFSET = $F7
MATH_API_REG_2_VAL_BYTE_3_OFFSET = $F6
MATH_API_REG_2_VAL_BYTE_2_OFFSET = $F5
MATH_API_REG_2_VAL_BYTE_1_OFFSET = $F4
MATH_API_REG_2_VAL_BYTE_0_OFFSET = $F3

; Generic API call macro
.macro API_CALL group_code, function_code
    lda #function_code
    sta API_FUNCTION
    lda #group_code
    sta API_COMMAND
    jsr WaitMessage
.endmacro


;--------------------------------------;
; End of Neo6502 Kernel API macros   ;
;--------------------------------------;