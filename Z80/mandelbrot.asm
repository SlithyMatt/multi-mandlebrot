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
   push bc                    ; preserve BC (X,Y)
   ld c,0                     ; BC = X
   ld de,mand_xmax            ; DE = Xmax
   call fp_multiply           ; HL = X*Xmax
   ld c,l                     ; BC = X*Xmax
   ld b,h
   ld d,mand_width            ; DE = width
   ld e,0
   call fp_divide             ; HL = X*Xmax/width
   ld de,mand_xmin            ; DE = Xmin
   add hl,de                  ; HL = X*Xmax/width - Xmin
   ld (mand_x0),hl            ; X0 = HL
   pop bc                     ; retrieve X,Y from stack

   push bc                    ; put X,Y back on stack
   ld b,c
   ld c,0                     ;BC = Y
   ld de,mand_ymax            ;DE = Ymax
   call fp_multiply           ;HL = Y*Ymax
   ld c,l
   ld b,h                     ; BC = Y*Ymax
   ld d,mand_height           ; DE = height
   ld e,0
   call fp_divide             ; HL = Y*Ymax/height
   ld de,mand_ymin            ; DE = Ymin
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
   cp mand_max_it             ; is A == maxI
   jp nz,.loopi
   push af                    ; need to push af on stack since there is another branch to .dec_i
.dec_i:
   pop af                     ; A = I
   dec a                      ; A = I - 1
   pop bc                                                         ; restore BC (X,Y)
   ret
