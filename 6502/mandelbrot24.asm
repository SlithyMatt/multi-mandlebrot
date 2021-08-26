.include "fixedpt24.asm"

mand_xmin:     .dword $00FD80 ; -2.5
mand_xmax:     .dword $000380 ; 3.5
mand_ymin:     .dword $00FF00 ; -1
mand_ymax:     .dword $000200 ; 2

mand_width:    .word 320
mand_height:   .word 200
mand_max_it:   .word 48

mand_x0:       .dword 0
mand_y0:       .dword 0
mand_x:        .dword 0
mand_y:        .dword 0
mand_x2:       .dword 0
mand_y2:       .dword 0
mand_xtemp:    .dword 0

mand_get:   ; Input:
            ;  mand_x,mand_y - bitmap coordinates
            ; Output: A - # iterations executed (0 to mand_max_it-1)
   FP_LDA_WORD mand_x ; A = X coordinate
   FP_LDB mand_xmax  ; B = max scaled X
   jsr fp_multiply   ; C = A*B
   FP_TCA            ; A = C (X*Xmax)
   FP_LDB_WORD mand_width ; B = width
   jsr fp_divide     ; C = A/B
   FP_TCA            ; A = C (scaled X with zero min)
   FP_LDB mand_xmin  ; B = min scaled X
   jsr fp_add        ; C = A+B (scaled X)
   FP_STC mand_x0    ; x0 = C
   FP_LDA_WORD mand_y ; A = Y coordinate
   FP_LDB mand_ymax  ; B = max scaled Y
   jsr fp_multiply   ; C = A*B
   FP_TCA            ; A = C (Y*Ymax)
   FP_LDB_WORD mand_height ; B = height
   jsr fp_divide     ; C = A/B
   FP_TCA            ; A = C (scaled Y with zero min)
   FP_LDB mand_ymin  ; B = min scaled Y
   jsr fp_add        ; C = A+B (scaled Y)
   FP_STC mand_y0    ; y0 = C
.if (.cpu .bitand ::CPU_ISET_65SC02)
   stz mand_x
   stz mand_x+1
   stz mand_x+2
   stz mand_y
   stz mand_y+1
   stz mand_y+2
.else
   lda #0
   sta mand_x
   sta mand_x+1
   stz mand_x+2
   sta mand_y
   stz mand_y+1
   sta mand_y+2
.endif
   ldx #0            ; X = I (init to 0)
@loop:
   FP_LDA mand_x     ; A = X
   FP_LDB mand_x     ; B = X
   jsr fp_multiply   ; C = X^2
   FP_STC mand_x2
   FP_LDA mand_y     ; A = Y
   FP_LDB mand_y     ; B = Y
   jsr fp_multiply   ; C = Y^2
   FP_STC mand_y2
   FP_LDA mand_x2    ; A = X^2
   FP_TCB            ; B = Y^2
   jsr fp_add        ; C = X^2+Y^2
   lda FP_C+1
   sec
   sbc #4
   beq @check_fraction
   bmi @do_it
   jmp @dec_i
@check_fraction:
   lda FP_C
   bne @dec_i
@do_it:
   jsr fp_subtract   ; C = X^2 - Y^2
   FP_TCA            ; A = C (X^2 - Y^2)
   FP_LDB mand_x0    ; B = X0
   jsr fp_add        ; C = X^2 - Y^2 + X0
   FP_STC mand_xtemp ; Xtemp = C
   lda #2
   jsr fp_lda_byte   ; A = 2
   FP_LDB mand_x     ; B = X
   jsr fp_multiply   ; C = 2*X
   FP_TCA            ; A = C (2*X)
   FP_LDB mand_y     ; B = Y
   jsr fp_multiply   ; C = 2*X*Y
   FP_TCA            ; A = C (2*X*Y)
   FP_LDB mand_y0    ; B = Y0
   jsr fp_add        ; C = 2*X*Y + Y0
   FP_STC mand_y     ; Y = C (2*X*Y + Y0)
   lda mand_xtemp
   sta mand_x
   lda mand_xtemp+1
   sta mand_x+1      ; X = Xtemp
   inx
   cpx mand_max_it
   beq @dec_i
   jmp @loop
@dec_i:
   dex
   txa
   rts
