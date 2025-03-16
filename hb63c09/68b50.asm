; UART and control the routines are set up for the 6850
; or 'like' such as the 6850 Wrapper in the HB63C09M.

USTAT   EQU $A000           ; UART Status Register
UDATA   EQU $A001           ; UART Data Register

; Send CRLF to terminal
CRLF:   LDA #$0A               ; Line feed
        BSR CHOUT
        LDA #$0D               ; Carriage return
        BSR CHOUT
        RTS

; Map iterations to printable ASCII characters
PLOT:   LDA 6,S                ; Load iteration count
        INCA                   ; Offset for gradient lookup
        LDY #PSUSHD            ; Address of gradient table
        LDA A,Y                ; Load corresponding ASCII shade
; Fall through to `CHOUT`

CHOUT:  PSHS A                 ; Save character in A
WRWAIT: LDA USTAT              ; Check UART status
        BITA #2                ; Ready to send?
        BEQ WRWAIT             ; Wait until ready
        PULS A                 ; Restore character
        STA UDATA              ; Send character
        RTS


; 16 levels of pseudo-shades in 7-Bit ASCII (darkest to lightest)
PSUSHD: FCB $23,$40,$25,$26,$58,$2A,$2B,$3D ; Darker characters
        FCB $2D,$7E,$3A,$2E,$2C,$60,$20,$20 ; Lighter characters