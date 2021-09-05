!to "man.prg", cbm
!cpu m65
!convtab pet

!source "mega65defs.asm"
!source "manddefs.asm"
!source "fixedptdefs.asm"
REVERSE_SPACE     = $A0

        * = $2001               ; start of basic for mega65

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
        !word @line20, 10       ; line 10
        !byte $9c               ; CLR
        !text " ti"             ; TI
        !byte 0                 ; eol
@line20:
        !word @line30, 20       ; line 20
        !byte $fe, $02          ; BANK
        !text "0:"              ; 0:
        !byte $9e               ; SYS $9e
        ; start address in hex as ascii codes
        !text "$"
@this:                          ; macro won't work with forward def'ed label
        +label2hexstr @this+43  ; 4 bytes hexstr, 3 bytes 0 (eol and eop)
        !byte 0                 ; eol
@line30:
        !word @line40, 30       ; line 30
        !text "et", $b2, "ti"   ; et=ti
        !byte 0                 ; eol
@line40:
        !word @last, 40         ; line 40
        !byte $fe, $41, $91     ; cursor on
        !text ",35,1:"
        !byte $99               ; print
        !text "et:"             ; et:
        !byte $fe, $41, $91     ; cursor on
        !text ",1,21"
        !byte 0                 ; eol
@last:
        !word 0                 ; eop

start:
        jmp init

init:
        lda #0
        ldx #0
        ldy #0
        ldz #%10110000
        map                     ; set memory map to give us IO and some ROM (right?)
        lda #0
        sta DMA_ADDRBANK
        lda #>dma_cls
        sta DMA_ADDRMSB
        lda #<dma_cls
        sta DMA_ADDRLSB_TRIG    ; clear screen using dma
        eom                     ; allow NMI/IRQ again (but mapping stays?)

;
; MANDELBROT LOOP
;
        ldz #0                  ; 4502 has z register, we need it to be zero
        lda #base_page
        tab                     ; set base-page to FP_BP
        sei
        lda #0
        sta mand_scrn+3
        sta mand_colr+3
        lda #M65_SCREEN_BANK
        sta mand_scrn+2
        lda #>M65_SCREEN
        sta mand_scrn+1
        lda #<M65_SCREEN
        sta mand_scrn
        lda #M65_COLRAM_BANK
        sta mand_colr+2
        lda #>M65_COLRAM
        sta mand_colr+1
        lda #<M65_COLRAM
        sta mand_colr
        ldx #0
        ldy #0
@loop:
        jsr mand_get            ; no need to store A, because result is also in mand_res
        txa
        taz
        lda #REVERSE_SPACE
        sta [mand_scrn],z
        lda mand_res
        sta [mand_colr],z
        ldz #0
        inx
        cpx #MAND_WIDTH
        bne @loop
        ldx #0
        clc
        ; next line
        lda mand_scrn
        adc #80
        sta mand_scrn
        lda mand_scrn+1
        adc #0
        sta mand_scrn+1
        clc
        lda mand_colr
        adc #80
        sta mand_colr
        lda mand_colr+1
        adc #0
        sta mand_colr+1
        iny
        cpy #MAND_HEIGHT
        bne @loop
        clc
        lda #0
        tab                     ; reset base-page to 0
        cli
        rts



        sty FP_A
        stz FP_A+1
        asl FP_A
        rol FP_A+1
        asl FP_A
        rol FP_A+1
        asl FP_A
        rol FP_A+1
        asl FP_A
        rol FP_A+1
        lda FP_A+1
        sta FP_B+1
        lda FP_A
        sta FP_B                ; FP_B = Y*16
        asl FP_A
        rol FP_A+1
        asl FP_A
        rol FP_A+1
        asl FP_A
        rol FP_A+1              ; FP_A = Y*64
        clc
        adc FP_A
        sta FP_A
        lda FP_A+1
        adc FP_B+1
        sta FP_A+1              ; FP_A = Y*80
        ;lda FP_A no effect?
        txa
        adc FP_A
        sta FP_A
        sta FP_B
        lda FP_A+1
        adc #0
        sta FP_A+1              ; FP_A = Y*80+X
        sta FP_B+1              ; FP_B = Y*80+X
        lda FP_A
        adc #<M65_SCREEN
        sta FP_A
        lda FP_A+1
        adc #>M65_SCREEN
        sta FP_A+1
        phx
        ldx #0
        lda mand_res
        adc #$30
        sta (FP_A,x)         ; place reverse space character code
;        lda FP_B
;        adc #<M65_COLRAM
;        sta FP_B
;        lda FP_B+1
;        adc #>M65_COLRAM
;        sta FP_B+1
;        lda mand_res
;        sta (FP_B,x)         ; set color index
        plx
        inx
        cpx #MAND_WIDTH
;        bne @loop
        ldx #0
        iny
        cpy #MAND_HEIGHT
;        bne @loop
        clc
        lda #0
        tab                     ; reset base-page to 0
        cli
        rts

;
; TEST - fill screen with A
; to see if TI works...
;
        lda #$30
        tab                     ;  set base-page to $30xx
        lda #<M65_SCREEN
        sta $74
        lda #>M65_SCREEN
        sta $75
        lda #1
        ldx #7
--      ldy #0
-       sta ($74),y
        dey
        bne -
        ldy $75
        iny
        sty $75
        dex
        bne --
        ldy #208
-       sta ($74),y
        dey
        bne -
        sta ($74),y
        lda #0                  ; set base-page to $00xx
        tab
        rts

dma_cls:
        ; two dma command blocks chained
        ; clear screen with space
        !byte DMA_FILL|DMA_CHAIN
        !word 80*25
        !word $0020     ; fill value SPACE
        !byte $00       ; src bank (ignored)
        !word M65_SCREEN
        !byte M65_SCREEN_BANK
        !byte $00       ; cmd msb (unused)
        !word $0000     ; modulo (ignored)
        ; set color to white
        !byte DMA_FILL
        !word 80*25
        !word $0001     ; fill value WHITE
        !byte $00       ; src bank (ignore)
        !word M65_COLRAM
        !byte M65_COLRAM_BANK
        !byte $00       ; cmd msb (unused)
        !word $0000     ; modulo (ignored)

!source "fixedpt.asm"

!source "mandelbrot.asm"
