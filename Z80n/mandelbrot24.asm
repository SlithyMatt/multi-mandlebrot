   include "fixedpt24.asm"

   IFNUSED MAND_XMIN
MAND_XMIN   = $FFFD80 ; -2.5
   ENDIF
   IFNUSED MAND_XMAX
MAND_XMAX   = $000380 ; 3.5
   ENDIF
   IFNUSED MAND_YMIN
MAND_YMIN   = $FFFEB0 ; -1.3125
   ENDIF
   IFNUSED MAND_YMAX
MAND_YMAX   = $0002A0 ; 2.625
   ENDIF

   IFNUSED MAND_WIDTH
MAND_WIDTH  = 128
   ENDIF
   IFNUSED MAND_HEIGHT
MAND_HEIGHT = 96
   ENDIF
   IFNUSED MAND_MAX_IT
MAND_MAX_IT = 22
   ENDIF

mand_i:        db 0

mand_x0:       dd 0
mand_y0:       dd 0
mand_x:        dd 0
mand_y:        dd 0
mand_x2:       dd 0
mand_y2:       dd 0
mand_xtemp:    ; also called mand_scratch to avoid confusion with original code
mand_scratch:  dd 0

mand_get:   ; Input:
            ;  B,C - X,Y bitmap coordinates
            ; Output: A - # iterations executed (0 to MAND_MAX_IT-1)
   push bc                    ; preserve BC (X,Y)
   ld h,0
   ld l,b
   ld b,h
   FP_LDB_WORD MAND_WIDTH
   call fp_divide             ; FP_A = X/width
   FP_LDB MAND_XMAX           ; FP_B = Xmax
   call fp_multiply           ; FP_A = X/width*Xmax
   FP_LDB MAND_XMIN           ; FP_B = Xmin
   FP_ADD                     ; FP_A = X/width*Xmax + Xmin
   FP_STA mand_x0             ; X0 = FP_A
   pop bc                     ; retrieve X,Y from stack

   push bc                    ; put X,Y back on stack
   ld h,0
   ld l,c
   ld b,h                     ; FP_A = Y
   FP_LDB MAND_YMAX           ; FP_B = Ymax
   call fp_multiply           ; FP_A = Y*Ymax
   FP_LDB_WORD MAND_HEIGHT    ; FP_B = height
   call fp_divide             ; FP_A = Y*Ymax/height
   FP_LDB MAND_YMIN           ; FP_B = Ymin
   FP_ADD                     ; FP_A = Y*Ymax/height + Ymin
   FP_STA mand_y0             ; Y0 = FP_A

   ld a,0                     ; I = 0
   ld (mand_x),a              ; X = 0
   ld (mand_x+1),a
   ld (mand_x+2),a
   ld (mand_y),a              ; Y = 0
   ld (mand_y+1),a
   ld (mand_y+2),a
.loopi:
   push af                    ; A = I
   FP_LDA_IND mand_x          ; FP_A = X
   FP_TAB                     ; FP_B = X
   call fp_multiply           ; FP_A = X^2
   FP_STA mand_scratch        ; save X^2 in scratch
   FP_LDA_IND mand_y          ; FP_A = Y
   FP_TAB                     ; FP_B = Y
   call fp_multiply           ; FP_A = Y^2
   FP_LDB_IND mand_scratch    ; FP_B = X^2
   FP_STA mand_scratch        ; save Y^2 in scratch
   FP_ADD                     ; FP_A = X^2+Y^2
   ld a,0
   or h
   jp nz,.dec_i               ; done iterating if X^2 + Y^2 >= 256
   ld a,4                     ; A = 4
   sub l                      ; A = 4 - int(X^2 + Y^2)
   jp c,.dec_i                ; if (4 - int(X^2 + Y^2) < 0)  -> exit
   jp nz,.do_it               ; if (4 - int(X^2 + Y^2) != 0) -> do_it
   ld a,b                     ; A = frac(X^2 + Y^2)
   or a                       ; z-flag set if A == 0
   jr nz,.dec_i               ; int(X^2 + Y^2) == 4  but frac(X^2 + Y^2) != 0 -> exit
.do_it:                       ; we get here with c-flag always clear
   FP_LDA_IND mand_scratch    ; FP_A = Y^2
   FP_EXAB                    ; FP_A = X^2, FP_B = Y^2
   FP_SUBTRACT                ; FP_A = X^2 - Y^2
   FP_LDB_IND mand_x0         ; FP_B = X0
   FP_ADD                     ; FP_A = X^2 - Y^2 + X0
   FP_STA mand_xtemp          ; Xtemp = FP_A
   FP_LDA_IND mand_x          ; FP_A = X
   sla b
   rl l
   rl h                       ; FP_A = 2*X
   FP_LDB_IND mand_y          ; FP_B = Y
   call fp_multiply           ; FP_A = 2*X*Y
   FP_LDB_IND mand_y0         ; FP_B = Y0
   FP_ADD                     ; FP_A = 2*X*Y + Y0
   FP_STA mand_y              ; Y = FP_A
   FP_LDA_IND mand_xtemp      ; FP_A = Xtemp
   FP_STA mand_x              ; X = FP_A
   pop af                     ; A = I
   inc a                      ; A = I + 1
   cp MAND_MAX_IT             ; is A == maxI
   jp nz,.loopi
   push af                    ; need to push af on stack since there is another branch to .dec_i
.dec_i:
   pop af                     ; A = I
   dec a                      ; A = I - 1
   pop bc                                                         ; restore BC (X,Y)
   ret
