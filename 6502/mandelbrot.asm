.include "fixedpt.asm"

.ifndef MAND_XMIN
MAND_XMIN = $FD80 ; -2.5
.endif
.ifndef MAND_XMAX
MAND_XMAX = $0380 ; 3.5
.endif
.ifndef MAND_YMIN
MAND_YMIN = $FF00 ; -1
.endif
.ifndef MAND_YMAX
MAND_YMAX = $0200 ; 2
.endif

.ifndef MAND_WIDTH
MAND_WIDTH = 32
.endif
.ifndef MAND_HEIGHT
MAND_HEIGHT = 22
.endif
.ifndef MAND_MAX_IT
MAND_MAX_IT = 15
.endif

mand_x0:       .word 0
mand_y0:       .word 0
mand_x:        .word 0
mand_y:        .word 0
mand_x2:       .word 0
mand_y2:       .word 0
mand_xtemp:    .word 0

mand_get:   ; Input:
            ;  X,Y - bitmap coordinates
            ; Output: A - # iterations executed (0 to MAND_MAX_IT-1)
.if (.cpu .bitand ::CPU_ISET_65SC02)
   phx
   phy
.else
   txa
   pha
   tya
   pha
.endif
   txa
   jsr fp_lda_byte   ; A = X coordinate
   FP_LDB_IMM MAND_XMAX  ; B = max scaled X
   jsr fp_multiply   ; C = A*B
   FP_TCA            ; A = C (X*Xmax)
   FP_LDB_IMM_INT MAND_WIDTH ; B = width
   jsr fp_divide     ; C = A/B
   FP_TCA            ; A = C (scaled X with zero min)
   FP_LDB_IMM MAND_XMIN  ; B = min scaled X
   jsr fp_add        ; C = A+B (scaled X)
   FP_STC mand_x0    ; x0 = C
   pla               ; retrieve Y from stack
   pha               ; put Y back on stack
   jsr fp_lda_byte   ; A = Y coordinate
   FP_LDB_IMM MAND_YMAX  ; B = max scaled Y
   jsr fp_multiply   ; C = A*B
   FP_TCA            ; A = C (Y*Ymax)
   FP_LDB_IMM_INT  MAND_HEIGHT ; B = height
   jsr fp_divide     ; C = A/B
   FP_TCA            ; A = C (scaled Y with zero min)
   FP_LDB_IMM MAND_YMIN  ; B = min scaled Y
   jsr fp_add        ; C = A+B (scaled Y)
   FP_STC mand_y0    ; y0 = C
.if (.cpu .bitand ::CPU_ISET_65SC02)
   stz mand_x
   stz mand_x+1
   stz mand_y
   stz mand_y+1
.else
   lda #0
   sta mand_x
   sta mand_x+1
   sta mand_y
   sta mand_y+1
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
   FP_LDA mand_x     ; A = X
   asl FP_A
   rol FP_A+1        ; A = 2*X
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
   cpx #MAND_MAX_IT
   beq @dec_i
   jmp @loop
@dec_i:
   dex
.if (.cpu .bitand ::CPU_ISET_65SC02)
   txa
   ply
   plx
.else
   stx mand_xtemp ; store I in temp variable
   pla
   tay
   pla
   tax
   lda mand_xtemp ; A = I
.endif
   rts
