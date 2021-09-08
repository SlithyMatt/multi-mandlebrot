!ifndef MEGA65DEFS {
MEGA65DEFS = 1

DMA_COPY  = %00000000
DMA_MIX   = %00000001
DMA_SWAP  = %00000010
DMA_FILL  = %00000011
DMA_CHAIN = %00000100

M65_SCREEN_BANK = 0
M65_COLRAM_BANK = 1

!address {
DMA_ADDRLSB_TRIG = $d700
DMA_ADDRMSB      = $d701
DMA_ADDRBANK     = $d702
M65_SCREEN       = $0800
M65_COLRAM       = $f800
}

!macro nyb2hexstr .v {
        !if (.v & $0f) < 10 {
                !text (.v & $0f) + $30
        } else {
                !text (.v & $0f) + $37
        }
}

!macro label2hexstr .v {
        +nyb2hexstr (>.v >> 4)
        +nyb2hexstr >.v
        +nyb2hexstr (<.v >> 4)
        +nyb2hexstr <.v
}

}
