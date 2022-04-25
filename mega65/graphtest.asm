!to "graphtest.prg", cbm
!cpu m65

!source "mega65defs.asm"

        * = $2100

; some locations need to be defined
!address        SCREENMEM = $3000
!address        GRAPHMEM  = $0000 ; this is character ram
                GRAPHBNK  = $04   ; at $40000
!address        vicstate  = $f0   ; basepage

init:

	;; Enable VIC-IV with magic knock
	lda #$47
        sta VICIV_KEY
        lda #$53
        sta VICIV_KEY
        ;; Map Memory, still don't know what it really means
        lda #0
        ldx #0
        ldy #0
        ldz #%10110000
        map                     ; set memory map to give us IO and some ROM (right?)
        eom
        sei

        lda #0
        sta DMA_ADDRBANK
        lda #>dma_cls
        sta DMA_ADDRMSB
        lda #<dma_cls
        sta DMA_ADDRLSB_ETRIG   ; clear screen & charram
        lda #0
        sta DMA_ADDRBANK
        lda #>dma_clscol
        sta DMA_ADDRMSB
        lda #<dma_clscol
        sta DMA_ADDRLSB_ETRIG   ; clear colorram

        lda #$2f
        tab                     ; lets get some base page addresses for ourselfes

        ; store VIC states for later restore (in basepage)
        lda VICIII_SCRNMODE
        sta vicstate
        lda VICIV_SCRNMODE
        sta vicstate+1
        lda VICIV_SCRNPTR1
        sta vicstate+2
        lda VICIV_SCRNPTR2
        sta vicstate+3
        lda VICIV_SCRNPTR3
        sta vicstate+4
        lda VICIV_SCRNPTR4
        sta vicstate+5
        lda VICIV_LINESTEPLO
        sta vicstate+6
        lda VICIV_LINESTEPHI
        sta vicstate+7
        lda VICIV_PALETTE
        sta vicstate+8
        lda VICIV_CHRCOUNT
        sta vicstate+9
        
        ;; copied from basic.
        ;; 40x25 - 80x50 screen, with screen RAM at $A000-$BFFF, colour RAM at $FF80800-$FF827FF
        ;;
        ;; IMPORTANT: setting scrnmode must come before changing scrnptr!
        ;;
        lda #%10001000          ; clear H640 and V400 for 320x200
        trb VICIII_SCRNMODE
        lda #%00000101          ; set FCLRHI CHR16 for super extended attr mode
        tsb VICIV_SCRNMODE

        lda #80
        sta VICIV_LINESTEPLO
        lda #0
        sta VICIV_LINESTEPHI    ; one line of 40 chars is 80 byte

        lda #40
        sta VICIV_CHRCOUNT

        lda #<SCREENMEM
        sta VICIV_SCRNPTR1
        lda #>SCREENMEM
        sta VICIV_SCRNPTR2
        lda #0
        sta VICIV_SCRNPTR3
        sta VICIV_SCRNPTR4      ; set SCRNPTR to 0003000

        sta VICIV_BORDERCOL
        sta VICIV_SCREENCOL     ; black back and border

        lda #%11000000
        bit VICIV_PALETTE
        beq +
        lda #0
+       sta VICIV_PALETTE       ; toggle palette to something else

        ; copy palette
        lda #0
        sta DMA_ADDRBANK
        lda #>dma_copypal
        sta DMA_ADDRMSB
        lda #<dma_copypal
        sta DMA_ADDRLSB_ETRIG   ; copy commander x16 palette

        ; fill screen with pointers to $40000 y by x
        lda #$0
        sta $12
        sta $13         ; set high word of addr ptr to $0000
        sta $14
        lda #$10
        sta $15         ; set $14 to current charcode $1000 = $40000 absolute
        ldx #0          ; x loop index and z base
scrnfilx:
        lda #0
        sta $10
        lda #$30
        sta $11         ; set low word of addr ptr to $3000
        ldy #25         ; y loop counter
scrnfily:
        txa
        taz             ; use x as z index
        lda $14
        sta [$10],z     ; put low byte of char on screen
        inz             ; next index
        lda $15
        sta [$10],z     ; put high byte of char on screen
        dez             ; prev index
;        inc $14
;        bne +
;        inc $15         ; increment character by one
+       lda #80
        clc
        adc $10
        sta $10
        bcc +
        inc $11         ; add 80 to pointer
+       dey
        bne scrnfily    ; next y
        inx
        inx             ; inc x index by 2
        cpx #80         ; cmp to 80 (end of line)
        bne scrnfilx

        ; fill char $1000 with colors
        lda #$0
        sta $10
        sta $11
        sta $13
        lda #$04
        sta $12
        ldz #0
        ldx #64
        lda #128
-       sta [$10],z
        inc
        inz
        dex
        bne -

        jsr waitkey

        ; fill char $1000 with other colors
        lda #$0
        sta $10
        sta $11
        sta $13
        lda #$04
        sta $12
        ldz #0
        ldx #64
        lda #16
-       sta [$10],z
        inc
        inz
        dex
        bne -

        jsr waitkey

        lda #0
        sta $3053
        sta $3055
        sta $3057
        sta $3059
        lda #1
        sta $3052
        lda #2
        sta $3054
        lda #3
        sta $3056
        lda #4
        sta $3058

        jsr waitkey

restore:
        lda vicstate
        sta VICIII_SCRNMODE
        lda vicstate+1
        sta VICIV_SCRNMODE
        lda vicstate+6
        sta VICIV_LINESTEPLO
        lda vicstate+7
        sta VICIV_LINESTEPHI
        lda vicstate+9
        sta VICIV_CHRCOUNT
        lda vicstate+2
        sta VICIV_SCRNPTR1
        lda vicstate+3
        sta VICIV_SCRNPTR2
        lda vicstate+4
        sta VICIV_SCRNPTR3
        lda vicstate+5
        sta VICIV_SCRNPTR4
        lda vicstate+8
        sta VICIV_PALETTE
        lda #6
        sta VICIV_SCREENCOL
        sta VICIV_BORDERCOL

        lda #0
        tab
        cli
        rts

waitkey:
        ; clear key buffer
-       lda UART_ASCIIKEY
        beq +
        sta UART_ASCIIKEY
        bra -
+
        ; wait for key
-       lda UART_ASCIIKEY
        beq -

        ; clear key buffer
-       lda UART_ASCIIKEY
        beq +
        sta UART_ASCIIKEY
        bra -
+       rts

dma_cls:
        ; clear screen with space
        !byte $0a, $00 ; 11 byte mode
        !byte DMA_FILL|DMA_CHAIN
        !word 2000      ; 2*40*25 (chr16 lowres)
        !word $0020     ; fill with space
        !byte $00       ; src bank (ignored)
        !word SCREENMEM ; dest
        !byte $00       ; destbnk(0-3) + flags
        !word $0000     ; modulo (ignored)
        ; clear character rom
        !byte $0a, $00  ; no enhanced options
        !byte DMA_FILL
        !word 64*40*25
        !word $0000     ; fill color 0
        !byte $00       ; src bank (ignored)
        !word GRAPHMEM  ; dest
        !byte GRAPHBNK  ; destbnk(0-3) + flags
        !word $0000     ; modulo (ignored)

dma_clscol:
        !byte $0a, $81, $ff, $00 ; 11 byte mode, dest bank $ff
        !byte DMA_FILL
        !word 2000      ; 2*40*25 (chr16 lowres)
        !word $0001     ; fill colour 1
        !byte $00       ; src bank (ignored)
        !word $0000     ; dest
        !byte $08       ; destbnk -> FF 8 0000
        !word $0000     ; modulo (ignored)

dma_copypal:
        !byte $0a, $00  ; 11 byte mode
        !byte DMA_COPY
        !word $300
        !word cmdx16pal
        !byte $00
        !word VICIII_PALRED
        !byte $80       ; dma visible(7)
        !word $0000

!source "x16pal.asm"
