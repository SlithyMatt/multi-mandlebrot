   org #4000

start:
   jp init

fp_remainder:
   dw 0

fp_i: ; loop index
   db 0

fp_scratch:
   dw 0

   MACRO FP_LDA_BYTE source
      ld b,source
      ld c,0
   ENDM

   MACRO FP_LDB_BYTE source
      ld d,source
      ld e,0
   ENDM

   MACRO FP_LDA_BYTE_IND address
      ld a,(address)
      ld b,a
      ld c,0
   ENDM

   MACRO FP_LDB_BYTE_IND address
      ld a,(address)
      ld d,a
      ld e,0
   ENDM

   MACRO FP_LDA source
      ld bc,source
   ENDM

   MACRO FP_LDB source
      ld de,source
   ENDM

   MACRO FP_LDA_IND address
      ld bc,(address)
   ENDM

   MACRO FP_LDB_IND address
      ld de,(address)
   ENDM

   MACRO FP_STC dest
      ld (dest),hl
   ENDM

fp_floor_byte: ; A = floor(FP_C)
   ld a,h
   bit 7,a
   ret z
   ld a,0
   cp l
   ld a,h
   ret z
   dec a
   ret

fp_floor: ; FP_C = floor(FP_C)
   bit 7,h
   jp z,zerofrac
   ld a,0
   cp l
   jp z,zerofrac
   dec h
.zerofrac:
   ld l,0
   ret

   MACRO FP_TCA ; FP_A = FP_C
      ld b,h
      ld c,l
   ENDM

   MACRO FP_TCB ; FP_B = FP_C
      ld d,h
      ld e,l
   ENDM

   MACRO FP_SUBTRACT ; FP_C = FP_A - FP_B
      ld h,b
      ld l,c
      or a
      sbc hl,de
   ENDM

   MACRO FP_ADD: ; FP_C = FP_A + FP_B
      ld h,b
      ld l,c
      add hl,de
   ENDM

fp_divide: ; FP_C = FP_A / FP_B; FP_REM = FP_A % FP_B
   push de              ; preserve FP_B
   bit 7,b
   jp nz,abs_a         ; get |FP_A| if negative
   ld h,b
   ld l,c               ; FP_C = FP_A
   jp check_sign_b
.abs_a:
   ld hl,0
   or a
   sbc hl,bc            ; FP_C = |FP_A|
.check_sign_b:
   bit 7,d
   jp z,shift_b
   push hl              ; preserve FP_C
   ld hl,0
   or a
   sbc hl,de
   ex de,hl             ; FP_B = |FP_B|
   pop hl               ; restore FP_C
.shift_b:
   ld e,d
   ld d,0
   push bc              ; preserve FP_A
   push de              ; copy FP_B
   exx                  ; to DE' register
   pop de
   ld hl,0              ; FP_R in HL' register
   exx
   ld b,16
.loop1:
   add hl,hl            ; Shift hi bit of FP_C into REM
   exx                  ; switch to alternative registers set
   adc hl,hl            ; 16-bit left shift
   ld a,l
   sub e                ; trial subtraction
   ld c,a
   ld a,h
   sbc a,d
   jp c,loop2          ; Did subtraction succeed?
   ld l,c               ; if yes, save it
   ld h,a
   exx                  ; switch to primary registers set
   inc l                ; and record a 1 in the quotient
   exx                  ; switch to alternative registers set
.loop2:
   exx                  ; switch to primary registers set
   djnz loop1          ; decrement register B and loop while B>0
   pop bc               ; restore FP_A
   pop de               ; restore FP_B
   bit 7,d
   jp nz,check_cancel
   bit 7,b
   ret z
   jp negative
.check_cancel:
   bit 7,b
   ret nz
.negative:
   push bc
   ld b,h
   ld c,l
   ld hl,0
   or a
   sbc hl,bc
   pop bc
   ret

fp_multiply ; FP_C = FP_A * FP_B; FP_R overflow
   push bc              ; preserve FP_A
   push de              ; preserve FP_B
   bit 7,b
   jp z,fpm_check_sign_b
   ld hl,0
   or a
   sbc hl,bc
   FP_TCA               ; FP_A = |FP_A|
fpm_check_sign_b:
   bit 7,d
   jp z,init_c
   ld hl,0
   or a
   sbc hl,de
   FP_TCB               ; FP_B = |FP_B|
.init_c:
   ld hl,0              ; fp_scratch in register H'
   exx                  ; fp_remainder in register L'
   ld hl,0
   exx                  ; switch to primary registers set
   ld a,16              ; fp_i in register A
fpm_loop1:
   srl d
   rr e
   jp nc,fpm_loop2
   add hl,bc
.fpm_loop2:
   rr h
   rr l
   exx                  ; switch to alternative registers set
   rr h
   rr l
   exx                  ; switch to primary registers set
   dec a
   jp nz,fpm_loop1
   ld a,l
   exx                  ; switch to alternative registers set
   ld e,a               ; we don't values in primary set anymore
   ld d,0               ; so will use alternative set as primary
   ld b,8            ; register B as loop counter
.loop3:
   srl d
   rr e
   rr h
   rr l
   djnz loop3       ; decrement and loop
   pop de            ; restore FP_B
   pop bc            ; restore FP_A
   bit 7,d
   jp nz,fpm_check_cancel
   bit 7,b
   ret z
   jp fpm_negative
fpm_check_cancel:
   bit 7,b
   ret nz
fpm_negative:
   push bc           ; preserve FP_A
   ld b,h
   ld c,l
   ld hl,0
   or a
   sbc hl,bc
   pop bc            ; restore FP_A
   ret

MAND_XMIN    equ #FD80 ; -2.5
MAND_XMAX   equ #0380 ; 3.5
MAND_YMIN    equ #FF00 ; -1
MAND_YMAX   equ #0200 ; 2

MAND_WIDTH   equ 32
MAND_HEIGHT equ 22
MAND_MAX_IT equ 15

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
            ; Output: 
            ;   A - # iterations executed (0 to MAND_MAX_IT-1)
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
   jp c,dec_i                ; if (4 - int(X^2 + Y^2) < 0)  -> exit
   jp nz,do_it               ; if (4 - int(X^2 + Y^2) != 0) -> do_it
   ld a,l                     ; A = frac(X^2 + Y^2)
   or a                       ; z-flag set if A == 0
   jr nz,dec_i               ; int(X^2 + Y^2) == 4  but frac(X^2 + Y^2) != 0 -> exit
.do_it:                       ; we get here with c-flag always clear
   ex de,hl                   ; HL = X^2
   sbc hl,bc                  ; HL = X^2 - Y^2
   ld de,(mand_x0)            ; DE = X0
   add hl,de                  ; HL =  X^2 - Y^2 + X0
   push hl                    ; Xtemp = HL
   ld bc,(mand_x)             ; BC = X
   ld de,#200                 ; DE = 2.0
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
   jp nz,loopi
   push af                    ; need to push af on stack since there is another branch to .dec_i
.dec_i:
   pop af                     ; A = I
   dec a                      ; A = I - 1
   pop bc                                                         ; restore BC (X,Y)
   ret


SCREEN_RAM              equ #C000
SET_MODE                  equ #BC0E

i_result: db 0
screen_ptr: dw 0

color_codes:
   db #C0,#0C,#CC,#30,#00,#3C,#FC
   db #03,#C3,#0F,#33,#F3,#3F,#FF,#F0

init:
   ld a,0
   call SET_MODE
   di
   ex af,af'
   push af
   ld bc,0              ; X = 0, Y = 0
.loopm:
   call mand_get
   ld ix,color_codes
   ld d,0
   ld e,a               ; DE = I
   add ix,de            ; IX = &(color code for I)
   ld h,0
   ld l,c               ; HL = Y
   sla l
   rl h
   sla l
   rl h
   sla l
   rl h
   sla l
   rl h                 ; HL = Y*16
   push hl
   pop de               ; DE = HL
   sla l
   rl h
   sla l
   rl h                 ; HL = Y*64
   add hl,de            ; HL = Y*80
   ld d,0
   ld e,b               ; DE = X
   sla e
   rl d                 ; DE = X*2
   add hl,de            ; HL = Y*80+X*2 (UL pixels of 4x8 square)
   ex hl,de
   ld hl,SCREEN_RAM
   add hl,de            ; HL = SCREEN_RAM+Y*80+X*2 (UL pixels of 4x8 square)
   ld d,4               ; column counter
   ld e,8               ; row counter
   ld a,(ix)
.loopp
   ld (hl),a
   inc hl
   dec d
   jp nz,loopp
   push de
   ld de,#7FC
   add hl,de
   pop de
   ld d,4
   dec e
   jp nz,loopp
   inc b                ; increment X
   ld a,MAND_WIDTH
   cp b
   jp nz,loopm         ; loop until X = width
   ld b,0               ; X = 0
   inc c                ; increment Y
   ld a,MAND_HEIGHT
   cp c
   jp nz,loopm         ; loop until Y = height
   pop af
   ex af,af'
   ei
   ret

