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
        !text ",65,2:"
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
        lda DMA_CONTROL
        ora #1
        sta DMA_CONTROL         ; enable F018B Style DMA
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
        sei                     ; we don't need no interruptions
        lda #base_page
        tab                     ; move base-page so we can use base page addresses for everything
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
        sta mand_colr           ; setup of the two 32bit base-page pointers to screen and colour ram
        ldx #0
        ldy #0                  ; loop counters
@loop:
        jsr mand_get            ; no need to store A, because result is also in mand_res
        txa
        clc
        rol                     
        taz                     ; z = x*2
        lda #REVERSE_SPACE
        sta [mand_scrn],z       ; reverse space to the screen
        inz
        sta [mand_scrn],z       ; double width
        dez
        lda mand_res
        sta [mand_colr],z       ; iterations as colour index to to cram
        inz
        sta [mand_colr],z       ; double width
        inx
        cpx #MAND_WIDTH
        bne @loop               ; next x
        ldx #0
        clc                     ; move mand_scrn bp pointer to the next line
        lda mand_scrn
        adc #80
        sta mand_scrn
        lda mand_scrn+1
        adc #0
        sta mand_scrn+1         ; mand_scrn += 80
        clc                     ; move mand_colr pointer to the next line
        lda mand_colr
        adc #80
        sta mand_colr
        lda mand_colr+1
        adc #0
        sta mand_colr+1         ; mand_colr += 80
        iny
        cpy #MAND_HEIGHT
        bne @loop               ; next y
        clc
        lda #0
        tab                     ; restore base-page to 0
        cli                     ; allow interrupts
        rts                     ; return

dma_cls:
        ; two dma command blocks chained
        ; set color to white
        !byte DMA_FILL|DMA_CHAIN
        !word 80*25
        !word $0001     ; fill value WHITE
        !byte $00       ; src bank (ignore)
        !word M65_COLRAM
        !byte M65_COLRAM_BANK
        !byte $00       ; cmd msb (unused)
        !word $0000     ; modulo (ignored)
        ; clear screen with space
        !byte DMA_FILL
        !word 80*25
        !word $0020     ; fill value SPACE
        !byte $00       ; src bank (ignored)
        !word M65_SCREEN
        !byte M65_SCREEN_BANK
        !byte $00       ; cmd msb (unused)
        !word $0000     ; modulo (ignored)

!source "fixedpt.asm"

!source "mandelbrot.asm"
