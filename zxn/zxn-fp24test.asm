   DEVICE ZXSPECTRUMNEXT

   org $8000

start:
	jp init

	include "../Z80n/fixedpt24.asm"

ENTER = $0D

result:  dd 0

init:
   nextreg $07,$03      ; set to 28 MHz
   exx                  ; save hl' register on stack
	push hl              ; to correct return into basic

   call print_result

   pop hl               ; restore hl' register
	exx                  ; from stack
   ret

print_result:
   ld a,(result+2)
   call print_hex
   ld a,(result+1)
   call print_hex
   ld a,(result)
   call print_hex
   ld a,ENTER
   rst $10
   ret

print_hex:
   push hl
   push af
   srl a
   srl a
   srl a
   srl a                ; A = A >> 4
   call print_hex_digit ; print high nybble
   pop af               ; restore A
   and $0F              ; clear high nybble
   call print_hex_digit ; print low nybble
   pop hl
   ret

print_hex_digit:
   cp $0A
   jp p,print_letter    ; if S clear, A >= $0A
   or $30               ; A < $0A, just put $3 in upper nybble for number code
   jp print_char
print_letter:
   add $37              ; A >= $0A, add $37 to get letter code
print_char:
   rst $10              ; print code for digit
   ret

; Deployment
LENGTH      = $ - start

;;; option 3: nex
	SAVENEX OPEN "test.nex",start
	SAVENEX AUTO
	SAVENEX CLOSE
