!ifndef MAND32DEFS_INC {
MAND32DEFS_INC = 1

;
; we are using 32bit fixed point intergers
; with a 4.28 setup (-8 to +7.99999999627471)
;

MAND_WIDTH  = 320       ; this is val>>6 / 5 (5*2**5)
MAND_HEIGHT = 200       ; this is val>>3 / 5 / 5 (25*2**3)
MAND_MAXIT  = 48

;
; we need some 32 bit base page variables
;
!address {
    ; this is our constant we will use in each iteration
    ; we need the start value, an increment per pixel and a current value

    ; screen extend in complex numbers
mand_rs    = $20    ; start real
mand_is    = $24    ; start imag
mand_re    = $28    ; end real
mand_ie    = $2c    ; end imag

    ; current c and increments
mand_cr    = $30    ; current point real
mand_ci    = $34    ; current point imag
mand_dr    = $38    ; per pixel increment real
mand_di    = $3c    ; per pixel increment imag

    ; iteration vars z, zr³, zi², zrtemp
mand_zr    = $40    ; iteration point real
mand_zi    = $44    ; iteration point imag
mand_zr2   = $48    ; zr²
mand_zi2   = $4c    ; zi²
mand_zrtmp = $50    ; temp var for real part
mand_iter  = $54    ; iteration counter (1 byte)

    ; graphic pointers
scrn_point = $10    ; start of one row (32b pointer)
scrn_row   = $14    ; current pixel (word)
scrn_x     = $16    ; word x pos 0-319
scrn_y     = $18    ; byte y pos 0-199

}

}
