;
; MEGA65 Mandelbrot
;
; Uses Hardware Math accelerator with 8.24 bit fractional numbers
;

; global start coordinates
mand_base_r0: !byte $00, $00, $80, $fd  ; -2.5
mand_base_r1: !byte $00, $00, $00, $01  ; +1.0
mand_base_i0: !byte $00, $00, $b0, $fe  ; -1.3125
mand_base_i1: !byte $00, $00, $50, $01  ; +1.3125

;
; mand_init: initialize 
mb_init:
        ; Calculates dx and dy from min/max coordinates
        ;
        ; mand_dr = (mand_base_r1 - mand_base_r0) / 320 (loose the rest..., ugly!)
        ;
        +FP_MOV mand_base_r1, FP_A
        +FP_MOV mand_base_r0, FP_B
        jsr fp_subtract           ; base_r1 - base_r0 -> FP_C
        +FP_MOV FP_C, FP_A        ; FP_C -> FP_A
        +FP_SR_X FP_A, 6          ; FP_A >> 6  (divide by 64)
        +FP_STOR_II 5, FP_B       ; we can't divide by 320, because we only have 8 bit
        jsr fp_divide             ; (base_r1 - base_r0) / 64 / 5 -> FP_C
        +FP_MOV FP_C, mand_dr
        ;
        ; mand_di = (mand_base_i1 - mand_base_i0) / 200 (loose the rest..., ugly!)
        ;
        +FP_MOV mand_base_i1, FP_A
        +FP_MOV mand_base_i0, FP_B
        jsr fp_subtract           ; base_i1 - base_i0 -> FP_C
        +FP_MOV FP_C, FP_A        ; FP_C -> FP_A
        +FP_SR_X FP_A, 3          ; FP_A >> 3  (divide by 8)
        +FP_STOR_II 5, FP_B       ; 5.0 -> FP_B
        jsr fp_divide             ; (base_i1 - base_i0) / 8 / 5 -> FP_C
        +FP_MOV FP_C, FP_A        ; FP_C -> FP_A, FP_B still 5.0
        jsr fp_divide             ; (base_i1 - base_i0) / 8 / 5 / 5 -> FP_C
        +FP_MOV FP_C, mand_di
        
        rts

mb_iter:
        rts
