!to "mand65.prg", cbm
!cpu m65
!convtab pet

!source "mega65defs.asm"
!source "mandelbrot32defs.asm"
!source "fixedpt32defs.asm"

        * = $2001               ; start of basic for mega65

; some locations need to be defined
!address        SCREENMEM = $3000
!address        GRAPHMEM  = $0000 ; this is character ram
                GRAPHBNK  = $04   ; at $40000
!address        vicstate  = $f0   ; basepage

!zone main
;;
;; Some rather complex BASIC
;; Calls the Assembler and outputs total running time by using
;; the RTC TI variable.
;;
;; 10 CLR TI
;; 20 BANK0:SYS$202E
;; 30 ET=TI
;; 40 CURSOR ON,35,1:PRINT ET:CURSOR ON,1,21
;;
basic:
        !word @last, 10          ; line 10
        !byte $fe, $02          ; BANK
        !text "0:"              ; 0:
        !byte $9e               ; SYS $9e
        ; start address in hex as ascii codes
        !text "$"
@this:                          ; macro won't work with forward def'ed label
        +label2hexstr @this+7   ; 4 bytes hexstr, 3 bytes 0 (eol and eop)
        !byte 0                 ; eol
@last:
        !word 0                 ; eop

start:
	;; Enable VIC-IV with magic knock
	lda #$47
        sta VICIV_KEY
        lda #$53
        sta VICIV_KEY
        ;; memory map
        lda #0
        ldx #0
        ldy #0
        ldz #%10110000
        map                     ; set memory map to give us IO and some ROM (right?)
        eom

        sei                     ; disable interupts
        cld                     ; no binary decimals
        lda #$2f
        tab                     ; move base-page so we can use base page addresses for everything

;
; Initialize Graphics
;
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
        ;; 40x25 - 80x50 screen, with screen RAM at $3000-$3FFF, colour RAM at $FF80000-$FF81FFF
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
        sta VICIV_CHRCOUNT      ; we are drawing only 40 chars

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
        sta scrn_point+2
        sta scrn_point+3 ; set high word of addr ptr to $0000
        sta scrn_row
        lda #$10
        sta scrn_row+1   ; set $14 to current charcode $1000 = $40000 absolute
        ldz #0           ; z loop index
scrnfilx:
        lda #<SCREENMEM
        sta scrn_point
        lda #>SCREENMEM
        sta scrn_point+1 ; set low word of addr ptr to $3000
        ldy #25          ; y loop counter
scrnfily:
        lda scrn_row
        sta [scrn_point],z      ; put low byte of char on screen
        inz                     ; next index
        lda scrn_row+1
        sta [scrn_point],z      ; put high byte of char on screen
        dez                     ; prev index
        inc scrn_row
        bne +
        inc scrn_row+1   ; increment character by one
+       lda #80
        clc
        adc scrn_point
        sta scrn_point
        bcc +
        inc scrn_point+1 ; add 80 to pointer
+       dey
        bne scrnfily    ; next y
        inz
        inz             ; inc x index by 2
        cpz #80         ; cmp to 80 (end of line)
        bne scrnfilx


;
; MANDELBROT
;
        jsr mb_init             ; initialize dr, di

        ; set cr
        +FP_MOV mand_base_r0, mand_cr
        lda #0
        sta scrn_x
        sta scrn_x+1            ; x = 0
        sta scrn_row
        sta scrn_row+1
        sta scrn_point
        sta scrn_point+1
        sta scrn_point+3
        lda #GRAPHBNK
        sta scrn_point+2        ; scrn_row = $0000, scrn_point = $0004.0000
xloop:
        ; set ci
        +FP_MOV mand_base_i0, mand_ci
        lda #200
        sta scrn_y              ; y = 200
yloop:
        ; do mandel stuff

        ; draw pixel
        lda scrn_y
        clc
        adc #32
        ldz #0
        sta [scrn_point],z

        +FP_MOV mand_ci, FP_A
        +FP_MOV mand_di, FP_B
        jsr fp_add
        +FP_MOV FP_C, mand_ci   ; advance c.i

        lda #8
        clc
        adc scrn_point
        sta scrn_point
        bcc +
        inc scrn_point+1        ; move point one down the row
+
        dec scrn_y              ; dec yloop counter
        bne yloop

        +FP_MOV mand_cr, FP_A
        +FP_MOV mand_dr, FP_B
        jsr fp_add
        +FP_MOV FP_C, mand_cr   ; advance c.r

        inc scrn_x
        bne +
        inc scrn_x+1
+       lda scrn_x+1
        cmp #$01
        bne @advrow
        lda scrn_x
        cmp #$40
        beq endloop

@advrow:
        inc scrn_row
        lda #7
        bit scrn_row
        bne @smallrow           ; check if we reached 8
        lda #<1592              ; one row of characters is 25*64-8
        clc
        adc scrn_row
        sta scrn_row
        sta scrn_point
        lda #>1592
        adc scrn_row+1          ; add 25*64-8 to scrn_row
        sta scrn_row+1
        sta scrn_point+1         ; and store also in scrn_point(loW)
        jmp xloop

@smallrow:
        lda scrn_row
        sta scrn_point
        lda scrn_row+1
        sta scrn_point+1
        jmp xloop

endloop:
        jsr waitkey

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
        tab                     ; restore base-page to 0
        cli                     ; allow interrupts
        rts                     ; return

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
        ; clear character rom
        !byte $0a, $00  ; no enhanced options
        !byte DMA_FILL
        !word 64*40*25
        !word $0000     ; fill tile 0
        !byte $00       ; src bank (ignored)
        !word GRAPHMEM  ; dest
        !byte GRAPHBNK  ; destbnk(0-3) + flags
        !word $0000     ; modulo (ignored)

dma_clscol:
        !byte $0a, $81, $ff, $00 ; 11 byte mode, dest bank $ff
        !byte DMA_FILL
        !word 2000      ; 2*40*25 (chr16 lowres)
        !word $0001     ; fill colour 1 (white)
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

!source "fixedpt32.asm"

!source "mandelbrot32.asm"

!source "x16pal.asm"
