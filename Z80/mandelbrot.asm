   include "fixedpt.asm"

mand_xmin:     equ $FD80 ; -2.5
mand_xmax:     equ $0380 ; 3.5
mand_ymin:     equ $FF00 ; -1
mand_ymax:     equ $0200 ; 2

mand_width:    equ 32
mand_height:   equ 22
mand_max_it:   equ 15

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
   push bc              ; preserve BC (X,Y)
   ld c,0                                     ;FP_LDA_BYTE b              ; A = X coordinate
   ld de,mand_xmax                            ;FP_LDB_IND mand_xmax       ; B = max scaled X
   call fp_multiply           ; HL = X*Xmax                               ; C = A*B
   ld c,l                     ; BC = X*Xmax   ;FP_TCA                     ; A = C (X*Xmax)
   ld b,h
   ld d,mand_width           ; DE = width    ;FP_LDB_BYTE_IND mand_width ; B = width
   ld e,0
   call fp_divide             ; HL = X*Xmax/width                         ; C = A/B
                                              ;FP_TCA                     ; A = C (scaled X with zero min)
   ld de,mand_xmin            ; DE = Xmin     ;FP_LDB_IND mand_xmin       ; B = min scaled X
   add hl,de                  ; HL = X*Xmax/width - Xmin ;FP_ADD           ; C = A+B (scaled X)
   ld (mand_x0),hl            ; X0 = HL       ;FP_STC mand_x0             ; x0 = C
   pop bc                     ; retrieve X,Y from stack
   push bc                    ; put X,Y back on stack
   ld b,c                                     ;FP_LDA_BYTE c              ; A = Y coordinate
   ld c,0                     ;BC = Y
   ld de,mand_ymax            ;DE = Ymax      ;FP_LDB_IND mand_ymax       ; B = max scaled Y
   call fp_multiply           ;HL = Y*Ymax                                ; C = A*B
   ld c,l                                     ;FP_TCA                     ; A = C (Y*Ymax)
   ld b,h                     ; BC = Y*Ymax
   ld d,mand_height           ; DE = height   ;FP_LDB_BYTE_IND mand_height; B = height
   ld e,0
   call fp_divide             ; HL = Y*Ymax/height                        ; C = A/B
                                              ;FP_TCA                     ; A = C (scaled Y with zero min)
   ld de,mand_ymin            ; DE = Ymin     ;FP_LDB_IND mand_ymin       ; B = min scaled Y
   add hl,de                  ; HL = Y*Ymax/height + Y
                                              ;FP_ADD                     ; C = A+B (scaled Y)
   ld (mand_y0),hl            ; Y0 = HL       ;FP_STC mand_y0             ; y0 = C
   ld hl,0
   ld (mand_x),hl             ; X = 0
   ld (mand_y),hl             ; Y = 0
                                      ;ld (ix),a
                                      ;ld (ix+1),a                ; X = 0
                                      ;ld (ix+2),a
                                      ;ld (ix+3),a                ; Y = 0
   xor a                              ;ld (mand_i),a              ; I = 0
.loopi:
   push af
   ld bc,(mand_x)        ;BC = X      ;FP_LDA_IND mand_x          ; A = X
   ld d,b                             ;FP_LDB_IND mand_x          ; B = X
   ld e,c                ;DE = X
   call fp_multiply      ;HL = X^2    ; C = X^2
   push hl               ;HL = X^2
   ld bc,(mand_y)        ;BC = Y      ;FP_LDA_IND mand_y          ; A = Y
   ld d,b                             ;FP_LDB_IND mand_y          ; B = Y
   ld e,c                ;DE = Y
   call fp_multiply      ;HL = Y^2    ; C = Y^2
   pop de                ;DE = X^2
   push de               ;DE = X^2
   push hl               ;HL = Y^2
                                      ;FP_STC mand_y2
                                      ;FP_LDA_IND mand_x2         ; A = X^2
                                      ;FP_TCB                     ; B = Y^2
                                      ;FP_ADD                     ; C = X^2+Y^2
   add hl,de             ;HL = X^2+Y^2
   pop bc                ;BC = Y^2
   pop de                ;DE = X^2
   ld a,4
   sub h                 ;H = int(X^2+Y^2)
   jp c,.dec_i           ;H>=4 -> exit
                                      ;jr z,.check_fraction
                                      ;jp nc,.do_it
   jp nz,.do_it          ;H!=4 -> next
                                      ;.check_fraction:
   ld a,l                ;L = frac(X^2+Y^2)
   or a
   jr nz,.dec_i          ;L>0 -> exit
.do_it:
   ex de,hl              ;HL = X^2
   sbc hl,bc             ;HL = X^2 - Y^2
                                      ;FP_SUBTRACT                ; C = X^2 - Y^2
                                      ;FP_TCA                     ; A = C (X^2 - Y^2)
   ld de,(mand_x0)       ;DE = X0     ;FP_LDB_IND mand_x0         ; B = X0
   add hl,de             ;HL =  X^2 - Y^2 + X0
                                      ; FP_ADD                     ; C = X^2 - Y^2 + X0
   push hl               ;Xtemp = HL  ;FP_STC mand_xtemp          ; Xtemp = C
                                      ; FP_LDA_BYTE 2              ; A = 2
   ld bc,(mand_x)        ;BC = X      ;FP_LDB_IND mand_x          ; B = X
   ld de,$200            ;DE = 2.0
   call fp_multiply      ;HL = 2*X
                                      ;call fp_multiply           ; C = 2*X
   ex de,hl              ;DE = 2*X    ;FP_TCA                     ; A = C (2*X)
   ld bc,(mand_y)        ;BC = Y      ;FP_LDB_IND mand_y          ; B = Y

   call fp_multiply      ;HL = 2*X*Y                              ; C = 2*X*Y
                                      ;FP_TCA                     ; A = C (2*X*Y)
   ld de,(mand_y0)       ;DE = Y0     ;FP_LDB_IND mand_y0         ; B = Y0
   add hl,de             ;HL = 2*X*Y + Y0
                                      ;FP_ADD                     ; C = 2*X*Y + Y0
   ld (mand_y),hl        ;Y = HL      ;FP_STC mand_y              ; Y = C (2*X*Y + Y0)
   pop hl                ;HL = Xtemp  ;ld hl,(mand_xtemp)
   ld (mand_x),hl        ;X = HL                                  ; X = Xtemp
   pop af                ;A = I       ; ld hl,mand_i
   inc a                 ;A = I + 1   ; inc (hl)
   cp mand_max_it
                                      ; cp (hl)
   jp nz,.loopi
   push af
.dec_i:
   pop af
                                      ;ld a,(mand_i)
   dec a                                                          ; A = I
   pop bc                                                         ; restore BC (X,Y)
   ret
