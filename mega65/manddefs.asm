!ifndef MANDDEFS_INC {
MANDDEFS_INC = 1

!ifndef MAND_XMIN {
MAND_XMIN = $FD80 ; -2.5
}
!ifndef MAND_XMAX {
MAND_XMAX = $0380 ; 3.5
}
!ifndef MAND_YMIN {
MAND_YMIN = $FF00 ; -1
}
!ifndef MAND_YMAX {
MAND_YMAX = $0200 ; 2
}

!ifndef MAND_WIDTH {
MAND_WIDTH = 32
}
!ifndef MAND_HEIGHT {
MAND_HEIGHT = 22
}
!ifndef MAND_MAX_IT {
MAND_MAX_IT = 15
}

base_page  = $2A
!address {
mand_x0    = $20
mand_y0    = $22
mand_x     = $24
mand_y     = $26
mand_x2    = $28
mand_y2    = $2A
mand_xtemp = $2C
mand_res   = $2e
mand_scrn  = $30
mand_colr  = $34
}

}
