.org $7000
.segment "LIBRARY"

.include "../6502/fixedpt24.asm"

fp_tca_sr:
   FP_TCA
   rts

fp_tcb_sr:
   FP_TCB
   rts

.org $9000
.segment "LIBVECS"
   jmp fp_add        ; 9000
   jmp fp_subtract   ; 9003
   jmp fp_multiply   ; 9006
   jmp fp_divide     ; 9009
   jmp fp_floor      ; 900C
   jmp fp_tca_sr     ; 900F
   jmp fp_tcb_sr     ; 9012
