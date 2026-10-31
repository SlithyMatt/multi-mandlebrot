.ifndef N6API_MACROS_BASE_INC
.include "n6apimacros_base.inc"
.endif

;--------------------------------------------;
; Neo6502 Kernel Console API macros          ;
;--------------------------------------------;


.macro N6_PUTC_A ; output character code in A register to console
    sta API_PARAMETERS+0
    API_CALL API_GROUP_CONSOLE, API_FN_WRITE_CHAR
.endmacro

.macro N6_PUTC char_code ; output character to console
    lda #char_code
    N6_PUTC_A
.endmacro

.macro N6_GETC ; get character from console input
    API_CALL API_GROUP_CONSOLE, API_FN_READ_CHAR
    ; result in API_PARAMETERS+0 (null if no character available)
.endmacro

.macro N6_WAIT_FOR_KEYPRESS ; wait for a keypress
.local loop
loop:   
    API_CALL API_GROUP_CONSOLE, API_FN_CONSOLE_STATUS
    lda API_PARAMETERS+0
    bne loop ; loop until keypress available
.endmacro

.macro N6_READ_LINE str_addr ; read line of input into str_addr buffer
    lda #<str_addr
    sta API_PARAMETERS+0
    lda #>str_addr
    sta API_PARAMETERS+1
    API_CALL API_GROUP_CONSOLE, API_FN_READ_LINE
    ; length-prefixed string at str_addr
.endmacro

.macro N6_DEFINE_HOTKEY hotkey_code, str_addr ; define hotkey to trigger string output
    lda #hotkey_code
    sta API_PARAMETERS+0
    lda #<str_addr
    sta API_PARAMETERS+2
    lda #>str_addr
    sta API_PARAMETERS+3
    API_CALL API_GROUP_CONSOLE, API_FN_DEFINE_HOTKEY
.endmacro

.macro N6_DEFINE_F1 str_addr ; define F1 key to trigger string output
    N6_DEFINE_HOTKEY 1, str_addr
.endmacro

.macro N6_DEFINE_F2 str_addr ; define F2 key to trigger string output
    N6_DEFINE_HOTKEY 2, str_addr
.endmacro

.macro N6_DEFINE_F3 str_addr ; define F3 key to trigger string output
    N6_DEFINE_HOTKEY 3, str_addr
.endmacro

.macro N6_DEFINE_F4 str_addr ; define F4 key to trigger string output
    N6_DEFINE_HOTKEY 4, str_addr
.endmacro

.macro N6_DEFINE_F5 str_addr ; define F5 key to trigger string output
    N6_DEFINE_HOTKEY 5, str_addr
.endmacro

.macro N6_DEFINE_F6 str_addr ; define F6 key to trigger string output
    N6_DEFINE_HOTKEY 6, str_addr
.endmacro

.macro N6_DEFINE_F7 str_addr ; define F7 key to trigger string output
    N6_DEFINE_HOTKEY 7, str_addr
.endmacro

.macro N6_DEFINE_F8 str_addr ; define F8 key to trigger string output
    N6_DEFINE_HOTKEY 8, str_addr
.endmacro

.macro N6_DEFINE_F9 str_addr ; define F9 key to trigger string output
    N6_DEFINE_HOTKEY 9, str_addr
.endmacro

.macro N6_DEFINE_F10 str_addr ; define F10 key to trigger string output
    N6_DEFINE_HOTKEY 10, str_addr
.endmacro

.macro N6_DEFINE_CHARACTER char_code, char_data_ptr ; define custom character
.local loop
    phx
    lda #char_code
    sta API_PARAMETERS+0
    ldx #6
loop:   
    lda char_data_ptr, x
    sta API_PARAMETERS+1, x
    dex
    bpl loop
    plx
    API_CALL API_GROUP_CONSOLE, API_FN_DEFINE_CHAR
.endmacro

.macro N6_LOCATE_CURSOR x_pos, y_pos ; set cursor position
    lda #x_pos
    sta API_PARAMETERS+0
    lda #y_pos
    sta API_PARAMETERS+1
    API_CALL API_GROUP_CONSOLE, API_FN_SET_CURSOR_POS
.endmacro

.macro N6_LIST_HOTKEYS ; list all defined hotkeys
    API_CALL API_GROUP_CONSOLE, API_FN_LIST_HOTKEYS
.endmacro

.macro N6_GET_SCREEN_SIZE ; get console screen size
    API_CALL API_GROUP_CONSOLE, API_FN_SCREEN_SIZE
    ; height in API_PARAMETERS+0, width in API_PARAMETERS+1
.endmacro

.macro N6_CLEAR_SCREEN ; clear the console screen
    API_CALL API_GROUP_CONSOLE, API_FN_CLEAR_SCREEN
.endmacro

.macro N6_GET_CURSOR_POS ; get current cursor position
    API_CALL API_GROUP_CONSOLE, API_FN_CURSOR_POS
    ; x position in API_PARAMETERS+0, y position in API_PARAMETERS+1
.endmacro

.macro N6_CLEAR_REGION begin_x, begin_y, end_x, end_y ; clear region of console
    lda #begin_x
    sta API_PARAMETERS+0
    lda #begin_y
    sta API_PARAMETERS+1
    lda #end_x
    sta API_PARAMETERS+2
    lda #end_y
    sta API_PARAMETERS+3
    API_CALL API_GROUP_CONSOLE, API_FN_CLEAR_REGIION
.endmacro

.macro N6_SET_TEXT_COLOR fg_color, bg_color ; set console text color
    lda #fg_color
    sta API_PARAMETERS+0
    lda #bg_color
    sta API_PARAMETERS+1
    API_CALL API_GROUP_CONSOLE, API_FN_SET_TEXT_COLOR
.endmacro

.macro N6_GET_TEXT_COLOR ; get console text color
    API_CALL API_GROUP_CONSOLE, API_FN_SET_TEXT_COLOR
    ; fg color in API_PARAMETERS+0, bg color in API_PARAMETERS+1
.endmacro

.macro N6_SHOW_CURSOR ; show console cursor
    lda #$01
    sta API_PARAMETERS+0
    API_CALL API_GROUP_CONSOLE, API_FN_SHOW_HIDE_CURSOR
.endmacro

.macro N6_HIDE_CURSOR ; hide console cursor
    lda #$00
    sta API_PARAMETERS+0
    API_CALL API_GROUP_CONSOLE, API_FN_SHOW_HIDE_CURSOR
.endmacro

.macro N6_PUTS str_addr ; output null-terminated string to console
    .local loop_start
    .local loop_end
    phx
    ldx #$00
loop_start:   
    lda str_addr, x
    beq loop_end ; end of string
    N6_PUTC_A
    inx
    bra loop_start
loop_end:   
    plx
.endmacro

.macro N6_PUTS_LEN_PRE str_addr ; output string with length prefix to console
    .local loop_start
    .local loop_end    
    phx
    ldx #str_addr
    beq loop_start ; zero-length string
loop_start:   
    lda str_addr, x
    N6_PUTC_A
    dex
    bne loop_end
loop_end:   
    plx
.endmacro

;--------------------------------------------;
; End of Neo6502 Kernel Console API macros   ;
;--------------------------------------------;
