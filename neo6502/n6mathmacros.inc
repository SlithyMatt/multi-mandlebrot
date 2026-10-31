.ifndef N6API_MACROS_BASE_INC
.include "n6apimacros_base.inc"
.endif

;-----------------------------------------;
; Neo6502 Kernel Math API macros          ;
;-----------------------------------------;

; Offsets can be calculated once Math API parameters 0-2 are set up
MATH_API_REG_1_TYPE = 0
MATH_API_REG_2_TYPE = 1

MATH_API_INT_TYPE    = $00 ; integer type
MATH_API_FLOAT_TYPE  = $01 ; floating-point type

; Should generally be called once at the the start of the program
.macro MATH_API_SETUP_ZP base_ptr, stride
    lda #<base_ptr
    sta MATH_API_ZP_BASE_PTR
    lda #>base_ptr
    sta MATH_API_ZP_BASE_PTR + 1
    lda #stride
    sta MATH_API_ZP_STRIDE
    lda #MATH_API_REG_1_TYPE
    clc
    adc MATH_API_ZP_STRIDE
    sta MATH_API_REG_1_VAL_BYTE_0_OFFSET
    inc
    sta MATH_API_REG_2_VAL_BYTE_0_OFFSET
    adc MATH_API_ZP_STRIDE
    sta MATH_API_REG_2_VAL_BYTE_1_OFFSET
    dec
    sta MATH_API_REG_1_VAL_BYTE_1_OFFSET
    adc MATH_API_ZP_STRIDE
    sta MATH_API_REG_1_VAL_BYTE_2_OFFSET
    inc
    sta MATH_API_REG_2_VAL_BYTE_2_OFFSET
    adc MATH_API_ZP_STRIDE
    sta MATH_API_REG_2_VAL_BYTE_3_OFFSET
    dec
    sta MATH_API_REG_1_VAL_BYTE_3_OFFSET
.endmacro

; Should be called before each Math API call
.macro MATH_API_SET_PARAMS
    lda MATH_API_ZP_BASE_PTR
    sta API_PARAMETERS
    lda MATH_API_ZP_BASE_PTR + 1
    sta API_PARAMETERS + 1
    lda MATH_API_ZP_STRIDE
    sta API_PARAMETERS + 2
.endmacro

.macro MATH_API_SET_REG1_TYPE type
    phy
    ldy #MATH_API_REG_1_TYPE
    lda #type
    sta (MATH_API_ZP_BASE_PTR), y
    ply
.endmacro

.macro MATH_API_SET_REG2_TYPE type
    phy
    ldy #MATH_API_REG_2_TYPE
    lda #type
    sta (MATH_API_ZP_BASE_PTR), y
    ply
.endmacro

.macro MATH_API_SET_REG1_INT 
    MATH_API_SET_REG1_TYPE MATH_API_INT_TYPE
.endmacro

.macro MATH_API_SET_REG2_INT 
    MATH_API_SET_REG2_TYPE MATH_API_INT_TYPE
.endmacro

.macro MATH_API_SET_REG1_FLOAT 
    MATH_API_SET_REG1_TYPE MATH_API_FLOAT_TYPE
.endmacro

.macro MATH_API_SET_REG2_FLOAT 
    MATH_API_SET_REG2_TYPE MATH_API_FLOAT_TYPE
.endmacro

; Immediate Loads

.macro MATH_API_SET_REG1 value
    phy
    ldy MATH_API_REG_1_VAL_BYTE_0_OFFSET
    lda #<value
    sta (MATH_API_ZP_BASE_PTR), y
    ldy MATH_API_REG_1_VAL_BYTE_1_OFFSET
    lda #>value
    sta (MATH_API_ZP_BASE_PTR), y
    ldy MATH_API_REG_1_VAL_BYTE_2_OFFSET
    lda #^value
    sta (MATH_API_ZP_BASE_PTR), y
    ldy MATH_API_REG_1_VAL_BYTE_3_OFFSET
    lda #(value >> 24)
    sta (MATH_API_ZP_BASE_PTR), y
    ply
.endmacro

.macro MATH_API_SET_REG2 value
    phy
    ldy MATH_API_REG_2_VAL_BYTE_0_OFFSET
    lda #<value
    sta (MATH_API_ZP_BASE_PTR), y
    ldy MATH_API_REG_2_VAL_BYTE_1_OFFSET
    lda #>value
    sta (MATH_API_ZP_BASE_PTR), y
    ldy MATH_API_REG_2_VAL_BYTE_2_OFFSET
    lda #^value
    sta (MATH_API_ZP_BASE_PTR), y
    ldy MATH_API_REG_2_VAL_BYTE_3_OFFSET
    lda #(value >> 24)
    sta (MATH_API_ZP_BASE_PTR), y
    ply
.endmacro

; 32-bit Load/Store Macros (for both integer and float)

.macro MATH_API_LOAD_REG1_DWORD dest_ptr
    phy
    ldy MATH_API_REG_1_VAL_BYTE_0_OFFSET
    lda dest_ptr
    sta (MATH_API_ZP_BASE_PTR), y
    ldy MATH_API_REG_1_VAL_BYTE_1_OFFSET
    lda dest_ptr + 1
    sta (MATH_API_ZP_BASE_PTR), y
    ldy MATH_API_REG_1_VAL_BYTE_2_OFFSET
    lda dest_ptr + 2
    sta (MATH_API_ZP_BASE_PTR), y
    ldy MATH_API_REG_1_VAL_BYTE_3_OFFSET
    lda dest_ptr + 3
    sta (MATH_API_ZP_BASE_PTR), y
    ply
.endmacro

.macro MATH_API_LOAD_REG2_DWORD dest_ptr
    phy
    ldy MATH_API_REG_2_VAL_BYTE_0_OFFSET
    lda dest_ptr
    sta (MATH_API_ZP_BASE_PTR), y
    ldy MATH_API_REG_2_VAL_BYTE_1_OFFSET
    lda dest_ptr + 1
    sta (MATH_API_ZP_BASE_PTR), y
    ldy MATH_API_REG_2_VAL_BYTE_2_OFFSET
    lda dest_ptr + 2
    sta (MATH_API_ZP_BASE_PTR), y
    ldy MATH_API_REG_2_VAL_BYTE_3_OFFSET
    lda dest_ptr + 3
    sta (MATH_API_ZP_BASE_PTR), y
    ply
.endmacro

.macro MATH_API_STORE_REG1_DWORD src_ptr
    phy
    ldy MATH_API_REG_1_VAL_BYTE_0_OFFSET
    lda (MATH_API_ZP_BASE_PTR), y
    sta src_ptr
    ldy MATH_API_REG_1_VAL_BYTE_1_OFFSET
    lda (MATH_API_ZP_BASE_PTR), y
    sta src_ptr + 1
    ldy MATH_API_REG_1_VAL_BYTE_2_OFFSET
    lda (MATH_API_ZP_BASE_PTR), y
    sta src_ptr + 2
    ldy MATH_API_REG_1_VAL_BYTE_3_OFFSET
    lda (MATH_API_ZP_BASE_PTR), y
    sta src_ptr + 3
    ply
.endmacro

.macro MATH_API_STORE_REG2_DWORD src_ptr
    phy
    ldy MATH_API_REG_2_VAL_BYTE_0_OFFSET
    lda (MATH_API_ZP_BASE_PTR), y
    sta src_ptr
    ldy MATH_API_REG_2_VAL_BYTE_1_OFFSET
    lda (MATH_API_ZP_BASE_PTR), y
    sta src_ptr + 1
    ldy MATH_API_REG_2_VAL_BYTE_2_OFFSET
    lda (MATH_API_ZP_BASE_PTR), y
    sta src_ptr + 2
    ldy MATH_API_REG_2_VAL_BYTE_3_OFFSET
    lda (MATH_API_ZP_BASE_PTR), y
    sta src_ptr + 3
    ply
.endmacro

; 24-bit Load/Store Macros (for integers only)

.macro MATH_API_LOAD_REG1_INT24 dest_ptr
    phy
    ldy MATH_API_REG_1_VAL_BYTE_0_OFFSET
    lda dest_ptr
    sta (MATH_API_ZP_BASE_PTR), y
    ldy MATH_API_REG_1_VAL_BYTE_1_OFFSET
    lda dest_ptr + 1
    sta (MATH_API_ZP_BASE_PTR), y
    ldy MATH_API_REG_1_VAL_BYTE_2_OFFSET
    lda dest_ptr + 2
    sta (MATH_API_ZP_BASE_PTR), y
    ldy MATH_API_REG_1_VAL_BYTE_3_OFFSET
    lda #0
    sta (MATH_API_ZP_BASE_PTR), y
    ply
.endmacro

.macro MATH_API_STORE_REG1_INT24
    phy
    ldy MATH_API_REG_1_VAL_BYTE_0_OFFSET
    lda (MATH_API_ZP_BASE_PTR), y
    sta src_ptr
    ldy MATH_API_REG_1_VAL_BYTE_1_OFFSET
    lda (MATH_API_ZP_BASE_PTR), y
    sta src_ptr + 1
    ldy MATH_API_REG_1_VAL_BYTE_2_OFFSET
    lda (MATH_API_ZP_BASE_PTR), y
    sta src_ptr + 2
    ply
.endmacro

.macro MATH_API_LOAD_REG2_INT24 dest_ptr
    phy
    ldy MATH_API_REG_2_VAL_BYTE_0_OFFSET
    lda dest_ptr
    sta (MATH_API_ZP_BASE_PTR), y
    ldy MATH_API_REG_2_VAL_BYTE_1_OFFSET
    lda dest_ptr + 1
    sta (MATH_API_ZP_BASE_PTR), y
    ldy MATH_API_REG_2_VAL_BYTE_2_OFFSET
    lda dest_ptr + 2
    sta (MATH_API_ZP_BASE_PTR), y
    ldy MATH_API_REG_2_VAL_BYTE_3_OFFSET
    lda #0
    sta (MATH_API_ZP_BASE_PTR), y
    ply
.endmacro

.macro MATH_API_STORE_REG2_INT24
    phy
    ldy MATH_API_REG_2_VAL_BYTE_0_OFFSET
    lda (MATH_API_ZP_BASE_PTR), y
    sta src_ptr
    ldy MATH_API_REG_2_VAL_BYTE_1_OFFSET
    lda (MATH_API_ZP_BASE_PTR), y
    sta src_ptr + 1
    ldy MATH_API_REG_2_VAL_BYTE_2_OFFSET
    lda (MATH_API_ZP_BASE_PTR), y
    sta src_ptr + 2
    ply
.endmacro

; 16-bit Load/Store Macros (for integers only)
.macro MATH_API_LOAD_REG1_INT16 dest_ptr
    phy
    ldy MATH_API_REG_1_VAL_BYTE_0_OFFSET
    lda dest_ptr
    sta (MATH_API_ZP_BASE_PTR), y
    ldy MATH_API_REG_1_VAL_BYTE_1_OFFSET
    lda dest_ptr + 1
    sta (MATH_API_ZP_BASE_PTR), y
    ldy MATH_API_REG_1_VAL_BYTE_2_OFFSET
    lda #0
    sta (MATH_API_ZP_BASE_PTR), y
    ldy MATH_API_REG_1_VAL_BYTE_3_OFFSET
    sta (MATH_API_ZP_BASE_PTR), y
    ply
.endmacro

.macro MATH_API_STORE_REG1_INT16 src_ptr
    phy
    ldy MATH_API_REG_1_VAL_BYTE_0_OFFSET
    lda (MATH_API_ZP_BASE_PTR), y
    sta src_ptr
    ldy MATH_API_REG_1_VAL_BYTE_1_OFFSET
    lda (MATH_API_ZP_BASE_PTR), y
    sta src_ptr + 1
    ply
.endmacro

.macro MATH_API_LOAD_REG2_INT16 dest_ptr
    phy
    ldy MATH_API_REG_2_VAL_BYTE_0_OFFSET
    lda dest_ptr
    sta (MATH_API_ZP_BASE_PTR), y
    ldy MATH_API_REG_2_VAL_BYTE_1_OFFSET
    lda dest_ptr + 1
    sta (MATH_API_ZP_BASE_PTR), y
    ldy MATH_API_REG_2_VAL_BYTE_2_OFFSET
    lda #0
    sta (MATH_API_ZP_BASE_PTR), y
    ldy MATH_API_REG_2_VAL_BYTE_3_OFFSET
    sta (MATH_API_ZP_BASE_PTR), y
    ply
.endmacro

.macro MATH_API_STORE_REG2_INT16 src_ptr
    phy
    ldy MATH_API_REG_2_VAL_BYTE_0_OFFSET
    lda (MATH_API_ZP_BASE_PTR), y
    sta src_ptr
    ldy MATH_API_REG_2_VAL_BYTE_1_OFFSET
    lda (MATH_API_ZP_BASE_PTR), y
    sta src_ptr + 1
    ply
.endmacro

; 8-bit Load/Store Macros (for integers only)
.macro MATH_API_LOAD_REG1_INT8 dest_ptr
    phy
    ldy MATH_API_REG_1_VAL_BYTE_0_OFFSET
    lda dest_ptr
    sta (MATH_API_ZP_BASE_PTR), y
    ldy MATH_API_REG_1_VAL_BYTE_1_OFFSET
    lda #0
    sta (MATH_API_ZP_BASE_PTR), y
    ldy MATH_API_REG_1_VAL_BYTE_2_OFFSET
    sta (MATH_API_ZP_BASE_PTR), y
    ldy MATH_API_REG_1_VAL_BYTE_3_OFFSET
    sta (MATH_API_ZP_BASE_PTR), y
    ply
.endmacro

.macro MATH_API_STORE_REG1_INT8 src_ptr
    phy
    ldy MATH_API_REG_1_VAL_BYTE_0_OFFSET
    lda (MATH_API_ZP_BASE_PTR), y
    sta src_ptr
    ply
.endmacro

.macro MATH_API_LOAD_REG2_INT8 dest_ptr
    phy
    ldy MATH_API_REG_2_VAL_BYTE_0_OFFSET
    lda dest_ptr
    sta (MATH_API_ZP_BASE_PTR), y
    ldy MATH_API_REG_2_VAL_BYTE_1_OFFSET
    lda #0
    sta (MATH_API_ZP_BASE_PTR), y
    ldy MATH_API_REG_2_VAL_BYTE_2_OFFSET
    sta (MATH_API_ZP_BASE_PTR), y
    ldy MATH_API_REG_2_VAL_BYTE_3_OFFSET
    sta (MATH_API_ZP_BASE_PTR), y
    ply
.endmacro

.macro MATH_API_STORE_REG2_INT8 src_ptr
    phy
    ldy MATH_API_REG_2_VAL_BYTE_0_OFFSET
    lda (MATH_API_ZP_BASE_PTR), y
    sta src_ptr
    ply
.endmacro

; Math API calls

.macro N6_ADD
    API_CALL API_GROUP_MATH, API_FN_ADD
    ; result in REG1
.endmacro

.macro N6_SUB
    API_CALL API_GROUP_MATH, API_FN_SUB
    ; result in REG1
.endmacro

.macro N6_MUL
    API_CALL API_GROUP_MATH, API_FN_MUL
    ; result in REG1
.endmacro

.macro N6_DIV
    API_CALL API_GROUP_MATH, API_FN_DIV
    ; result in REG1
.endmacro

.macro N6_DIV_INT
    API_CALL API_GROUP_MATH, API_FN_DIV_INT
    ; result in REG1
.endmacro

.macro N6_DIV_DEC
    API_CALL API_GROUP_MATH, API_FN_DIV_DEC
    ; result in REG1
.endmacro

.macro N6_MOD
    API_CALL API_GROUP_MATH, API_FN_MOD
    ; result in REG1
.endmacro

.macro N6_CMP
    API_CALL API_GROUP_MATH, API_FN_CMP
    lda API_PARAMETERS+0
    cmp #0
    ; N, Z, C set accordingly
.endmacro

.macro N6_NEG ; negate REG1
    API_CALL API_GROUP_MATH, API_FN_NEG
    ; result in REG1
.endmacro

.macro N6_FLOOR ; floor REG1 (float -> int)
    API_CALL API_GROUP_MATH, API_FN_FLOOR
    ; result in REG1
.endmacro

.macro N6_STR_TO_NUM str_addr ; first byte must be length
    lda #<str_addr
    sta API_PARAMETERS+4
    lda #>str_addr
    sta API_PARAMETERS+5
    API_CALL API_GROUP_MATH, API_FN_STR_TO_NUM
    ; result in REG1
.endmacro

.macro N6_NUM_TO_STR_LENGTH_PREFIX str_addr, max_length ; stringify REG1, first byte will be length
    .local set_length
    .local start_copy
    .local copy_loop
    phx
    phy
    API_CALL API_GROUP_MATH, API_FN_NUM_TO_STR
    lda API_PARAMETERS+4
    sta API_SOURCE_PTR
    lda API_PARAMETERS+5
    sta API_SOURCE_PTR + 1
    lda #max_length
    ldy #0
    cmp (API_SOURCE_PTR), y
    bcs set_length ; no need to truncate
    sta str_addr ; set length byte to max_length
    bra start_copy
set_length:  
    lda (API_SOURCE_PTR), y
    sta str_addr ; set length byte to actual length
start_copy:
    tax ; copy string bytes
copy_loop:
    iny
    lda (API_SOURCE_PTR), y
    sta str_addr,y
    dex
    bne copy_loop
    ply
    plx
    ; result string at str_addr (first byte is length)
.endmacro

.macro N6_NUM_TO_STR_NULL_TERM str_addr, max_length ; stringify REG1, null terminated
    .local start_copy
    .local copy_loop
    phx
    phy
    API_CALL API_GROUP_MATH, API_FN_NUM_TO_STR
    lda API_PARAMETERS+4
    sta API_SOURCE_PTR
    lda API_PARAMETERS+5
    sta API_SOURCE_PTR + 1
    lda #max_length
    ldy #0
    cmp (API_SOURCE_PTR), y
    bcs start_copy ; no need to truncate
    lda (API_SOURCE_PTR), y
start_copy:   
    tax
copy_loop:   
    iny
    lda (API_SOURCE_PTR), y
    dey
    sta str_addr,y
    iny
    dex
    bne copy_loop
    lda #0
    sta str_addr,y ; null terminator
    ply
    plx
    ; result string at str_addr (null terminated)
.endmacro

.macro N6_SQRT ; square root of REG1
    API_CALL API_GROUP_MATH, API_FN_SQRT
    ; result in REG1
.endmacro

.macro N6_RADIAN_MODE ; set math mode to radians
    stz API_PARAMETERS+0
    API_CALL API_GROUP_MATH, API_FN_SET_MODE
.endmacro

.macro N6_DEGREE_MODE ; set math mode to degrees
    lda #1
    sta API_PARAMETERS+0
    API_CALL API_GROUP_MATH, API_FN_SET_MODE
.endmacro

.macro N6_SINE ; sine of REG1 (in degrees or radians based on current mode)
    API_CALL API_GROUP_MATH, API_FN_SINE
    ; result in REG1
.endmacro

.macro N6_COS ; cosine of REG1 (in degrees or radians based on current mode)
    API_CALL API_GROUP_MATH, API_FN_COS
    ; result in REG1
.endmacro

.macro N6_TAN ; tangent of REG1 (in degrees or radians based on current mode)
    API_CALL API_GROUP_MATH, API_FN_TAN
    ; result in REG1
.endmacro

.macro N6_ATAN ; arctangent of REG1
    API_CALL API_GROUP_MATH, API_FN_ATAN
    ; result in REG1 (in degrees or radians based on current mode)
.endmacro

.macro N6_EXP ; e^REG1
    API_CALL API_GROUP_MATH, API_FN_EXP
    ; result in REG1
.endmacro

.macro N6_LOG ; natural logarithm of REG1
    API_CALL API_GROUP_MATH, API_FN_LOG
    ; result in REG1
.endmacro

.macro N6_ABS ; absolute value of REG1
    API_CALL API_GROUP_MATH, API_FN_ABS
    ; result in REG1
.endmacro

.macro N6_SIGN ; sign of REG1
    API_CALL API_GROUP_MATH, API_FN_SIGN
    ; result in REG1 (-1, 0, +1)
.endmacro

.macro N6_RND_INT ; random integer in REG1
    API_CALL API_GROUP_MATH, API_FN_RND_INT
    ; result in REG1
.endmacro

.macro N6_RND_DEC ; random float in REG1
    API_CALL API_GROUP_MATH, API_FN_RND_DEC
    ; result in REG1
.endmacro

.macro N6_INT_TO_DEC ; convert integer in REG1 to float
    API_CALL API_GROUP_MATH, API_FN_INT_TO_DEC
    ; result in REG1
.endmacro



;-----------------------------------------;
; End of Neo6502 Kernel Math API macros   ;
;-----------------------------------------;