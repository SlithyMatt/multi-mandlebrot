   DEVICE ZXSPECTRUMNEXT

   org $8000

start:
	jp init

	include "../Z80n/fixedpt24.asm"

ENTER = $0D

results:  dd 0,0,0

init:
   nextreg $07,$03      ; set to 28 MHz

   FP_LDA $012345 ; 291.26953125
   FP_LDB $001234 ; 18.203125
   call fp_multiply  ; a = 5302.01568604 ($14b604)
   FP_STA results
   call fp_divide    ; a = 294.556423611 ($01268E)
   FP_STA results+3


done:
   halt
   jp init


; Deployment
LENGTH      = $ - start

;;; option 3: nex
	SAVENEX OPEN "test.nex",start
	SAVENEX AUTO
	SAVENEX CLOSE
