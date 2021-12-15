   include "fixedpt24.asm"

   IFNUSED MAND_XMIN
MAND_XMIN   = $FFFD80 ; -2.5
   ENDIF
   IFNUSED MAND_XMAX
MAND_XMAX   = $000380 ; 3.5
   ENDIF
   IFNUSED MAND_YMIN
MAND_YMIN   = $FFFF00 ; -1
   ENDIF
   IFNUSED MAND_YMAX
MAND_YMAX   = $000200 ; 2
   ENDIF

   IFNUSED MAND_WIDTH
MAND_WIDTH  = 128
   ENDIF
   IFNUSED MAND_HEIGHT
MAND_HEIGHT = 96
   ENDIF
   IFNUSED MAND_MAX_IT
MAND_MAX_IT = 15
   ENDIF

mand_i:        db 0

mand_x0:       dd 0
mand_y0:       dd 0
mand_x:        dd 0
mand_y:        dd 0
mand_x2:       dd 0
mand_y2:       dd 0
mand_xtemp:    dd 0

mand_get:   ; Input:
            ;  B,C - X,Y bitmap coordinates
            ; Output: A - # iterations executed (0 to MAND_MAX_IT-1)
   push bc                    ; preserve BC (X,Y)
   ld c,0                     ; BC = X
   ld d,MAND_WIDTH            ; DE = width
   ld e,0
   call fp_divide             ; HL = X/width
   ld c,l                     ; BC = X/width
   ld b,h
   ld de,MAND_XMAX            ; DE = Xmax
   call fp_multiply           ; HL = X/width*Xmax
   ld de,MAND_XMIN            ; DE = Xmin
   add hl,de                  ; HL = X/width*Xmax - Xmin
   ld (mand_x0),hl            ; X0 = HL
   pop bc                     ; retrieve X,Y from stack

   push bc                    ; put X,Y back on stack
   ld b,c
   ld c,0                     ;BC = Y
   ld de,MAND_YMAX            ;DE = Ymax
   call fp_multiply           ;HL = Y*Ymax
   ld c,l
   ld b,h                     ; BC = Y*Ymax
   ld d,MAND_HEIGHT           ; DE = height
   ld e,0
   call fp_divide             ; HL = Y*Ymax/height
   ld de,MAND_YMIN            ; DE = Ymin
   add hl,de                  ; HL = Y*Ymax/height + Y
   ld (mand_y0),hl            ; Y0 = HL

   ld hl,0
   ld (mand_x),hl             ; X = 0
   ld (mand_y),hl             ; Y = 0
   xor a                      ; I = 0
.loopi:
   push af                    ; A = I
   ld bc,(mand_x)             ; BC = X
   ld d,b
   ld e,c                     ; DE = X
   call fp_multiply           ; HL = X^2
   push hl                    ; put X^2 on stack
   ld bc,(mand_y)             ; BC = Y
   ld d,b
   ld e,c                     ; DE = Y
   call fp_multiply           ; HL = Y^2
   pop de                     ; DE = X^2
   push de                    ; get X^2 from stack and put it back again
   push hl                    ; HL = Y^2
   add hl,de                  ; HL = X^2+Y^2
   pop bc                     ; BC = Y^2
   pop de                     ; DE = X^2
   ld a,4                     ; A = 4
   sub h                      ; A = 4 - int(X^2 + Y^2)
   jp c,.dec_i                ; if (4 - int(X^2 + Y^2) < 0)  -> exit
   jp nz,.do_it               ; if (4 - int(X^2 + Y^2) != 0) -> do_it
   ld a,l                     ; A = frac(X^2 + Y^2)
   or a                       ; z-flag set if A == 0
   jr nz,.dec_i               ; int(X^2 + Y^2) == 4  but frac(X^2 + Y^2) != 0 -> exit
.do_it:                       ; we get here with c-flag always clear
   ex de,hl                   ; HL = X^2
   sbc hl,bc                  ; HL = X^2 - Y^2
   ld de,(mand_x0)            ; DE = X0
   add hl,de                  ; HL =  X^2 - Y^2 + X0
   push hl                    ; Xtemp = HL
   ld bc,(mand_x)             ; BC = X
   ld de,$200                 ; DE = 2.0
   call fp_multiply           ; HL = 2*X
   ex de,hl                   ; DE = 2*X
   ld bc,(mand_y)             ; BC = Y
   call fp_multiply           ; HL = 2*X*Y
   ld de,(mand_y0)            ; DE = Y0
   add hl,de                  ; HL = 2*X*Y + Y0
   ld (mand_y),hl             ; Y = HL
   pop hl                     ; HL = Xtemp
   ld (mand_x),hl             ; X = HL
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
