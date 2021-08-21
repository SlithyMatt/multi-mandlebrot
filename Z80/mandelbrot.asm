   include "fixedpt.asm"

mand_xmin:     dw $FD80 ; -2.5
mand_xmax:     dw $0380 ; 3.5
mand_ymin:     dw $FF00 ; -1
mand_ymax:     dw $0200 ; 2

mand_width:    db 32
mand_height:   db 22
mand_max_it:   db 15

mand_i:        db 0

mand_x0:       dw 0
mand_y0:       dw 0
mand_x:        dw 0
mand_y:        dw 0
mand_x2:       dw 0
mand_y2:       dw 0
mand_xtemp:    dw 0

mand_get:   ; Input:
            ;  B,C - X,Y bitmap coordinates
            ; Output: A - # iterations executed (0 to mand_max_it-1)
   push bc                    ; preserve BC (X,Y)
   FP_LDA_BYTE b              ; A = X coordinate
   FP_LDB_IND mand_xmax       ; B = max scaled X
   call fp_multiply           ; C = A*B
   FP_TCA                     ; A = C (X*Xmax)
   FP_LDB_BYTE_IND mand_width ; B = width
   call fp_divide             ; C = A/B
   FP_TCA                     ; A = C (scaled X with zero min)
   FP_LDB_IND mand_xmin       ; B = min scaled X
   FP_ADD                     ; C = A+B (scaled X)
   FP_STC mand_x0             ; x0 = C
   pop bc                     ; retrieve X,Y from stack
   push bc                    ; put X,Y back on stack
   FP_LDA_BYTE c              ; A = Y coordinate
   FP_LDB_IND mand_ymax       ; B = max scaled Y
   call fp_multiply           ; C = A*B
   FP_TCA                     ; A = C (Y*Ymax)
   FP_LDB_BYTE_IND mand_height; B = height
   call fp_divide             ; C = A/B
   FP_TCA                     ; A = C (scaled Y with zero min)
   FP_LDB_IND mand_ymin       ; B = min scaled Y
   FP_ADD                     ; C = A+B (scaled Y)
   FP_STC mand_y0             ; y0 = C
   ld ix,mand_x
   ld a,0
   ld (ix),a
   ld (ix+1),a                ; X = 0
   ld (ix+2),a
   ld (ix+3),a                ; Y = 0
   ld (mand_i),a              ; I = 0
.loopi:
   FP_LDA_IND mand_x          ; A = X
   FP_LDB_IND mand_x          ; B = X
   call fp_multiply           ; C = X^2
   FP_STC mand_x2
   FP_LDA_IND mand_y          ; A = Y
   FP_LDB_IND mand_y          ; B = Y
   call fp_multiply           ; C = Y^2
   FP_STC mand_y2
   FP_LDA_IND mand_x2         ; A = X^2
   FP_TCB                     ; B = Y^2
   FP_ADD                     ; C = X^2+Y^2
   ld a,h
   sub 4
   jp z,.check_fraction
   jp m,.do_it
   jp .dec_i
.check_fraction:
   ld a,0
   cp l
   jp nz,.dec_i
.do_it:
   FP_SUBTRACT                ; C = X^2 - Y^2
   FP_TCA                     ; A = C (X^2 - Y^2)
   FP_LDB_IND mand_x0         ; B = X0
   FP_ADD                     ; C = X^2 - Y^2 + X0
   FP_STC mand_xtemp          ; Xtemp = C
   FP_LDA_BYTE 2              ; A = 2
   FP_LDB_IND mand_x          ; B = X
   call fp_multiply           ; C = 2*X
   FP_TCA                     ; A = C (2*X)
   FP_LDB_IND mand_y          ; B = Y
   call fp_multiply           ; C = 2*X*Y
   FP_TCA                     ; A = C (2*X*Y)
   FP_LDB_IND mand_y0         ; B = Y0
   FP_ADD                     ; C = 2*X*Y + Y0
   FP_STC mand_y              ; Y = C (2*X*Y + Y0)
   ld hl,(mand_xtemp)
   ld (mand_x),hl             ; X = Xtemp
   ld hl,mand_i
   inc (hl)
   ld a,(mand_max_it)
   cp (hl)
   jp nz,.loopi
.dec_i:
   ld a,(mand_i)
   dec a                      ; A = I
   pop bc                     ; restore BC (X,Y)
   ret
