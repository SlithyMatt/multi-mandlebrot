;; asembly battle royal for the HB63C09M
;; This simply resets the comptuer at the end of exicution, and should 
;; technically work on any homebrew computer with a serial MLM as long as 
;; there is a supported UART -- You should check the addresses in your
;; source file for the UART to make shure they align with your architecture 

;; Load this into MON09 or ASSIST09 with 'L' command by pasteing the .S19 
;; into the terminal.

;; lets enable 6309 since the CPU is required for the architecture of the computer
h6309   EQU 1
SWATCH  EQU $A03D               ; dumb stop watch routine
        ORG $1000               ; Jump to this location with G 1000 in MON09 or ASSIST9
CONFIG:
        ifdef h6309
	LDMD #1 		; h6309 native mode
        endif

        LDA     SWATCH          ;should display "start" and start the debugger watch
;; main loop
        LEAS    -5,S            ; Allocate 5 bytes on the stack
        CLR     ,S              ; Clear X (temp low byte)
        CLR     1,S             ; Clear X (temp high byte)
        CLR     2,S             ; Clear Y (temp low byte)
        CLR     3,S             ; Clear Y (temp high byte)
                                ; Dispite what mand_get says in mandelbrot.asm itterations is in 6,S
        
loop:
        LBSR    mand_get        ; Compute Mandelbrot for current position
        LBSR    PLOT            ; Map result to a gradient character and send it to UART

        LDD     ,S              ; Load X register
        ADDD    #1              ; Increment X
        STD     ,S              ; Save X back

        CMPD    #MAND_WIDTH     ; Check if X reached the width
        BNE     loop            ; If not, continue

        BSR     CRLF            ; Send CRLF to start a new line
        CLR     ,S              ; Reset X to 0
        CLR     1,S

        LDD     2,S             ; Load Y register
        ADDD    #1              ; Increment Y
        STD     2,S             ; Save Y back

        CMPD    #MAND_HEIGHT    ; Check if Y reached the height
        BNE     loop            ; If not, continue
        LEAS    5,S             ; Deallocate stack
        
DONE:       
        LDA     SWATCH          ; should print the milliseconds delay.
        ifdef h6309
	LDMD #0 		; h6809 emulation mode
        endif

        JMP [$FFFE]             ; Jump to reset vector

;; includes uart and multi-mandelbrot for 24 bit fp math for optimal results.

        INCLUDE "68b50.asm"
        
         
        INCLUDE "../6x09/mandelbrot24.asm" ; Include Mandelbrot and fixed-point routines
