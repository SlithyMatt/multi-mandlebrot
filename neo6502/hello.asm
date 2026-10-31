.org $0200

jmp start

.include "n6apimacros.inc"

hello_msg:
.asciiz "Hello, World!"

CR = $0D

start:
    N6_PUTS hello_msg
    N6_PUTC CR
    rts

