; Registers
PPUCTRL     = $2000	; VPHB SINN: NMI enable (V), PPU master/slave (P), sprite height (H), background tile select (B),
                     ;            sprite tile select (S), increment mode (I), nametable select (NN)
PPUMASK     = $2001	; BGRs bMmG: color emphasis (BGR), sprite enable (s),
                     ;            background enable (b), sprite left column enable (M), background left column enable (m), greyscale (G)
PPUSTATUS   = $2002	; VSO- ----: vblank (V), sprite 0 hit (S), sprite overflow (O); read resets write pair for $2005/$2006
OAMADDR     = $2003	; aaaa aaaa: OAM read/write address
OAMDATA     = $2004  ; dddd dddd: OAM data read/write
PPUSCROLL   = $2005  ; xxxx xxxx: fine scroll position (two writes: X scroll, Y scroll)
PPUADDR     = $2006  ; aaaa aaaa: PPU read/write address (two writes: most significant byte, least significant byte)
PPUDATA     = $2007  ; dddd dddd: PPU data read/write
OAMDMA      = $4014  ; aaaa aaaa: OAM DMA high address

; Colors
BLACK       = $1D
WHITE       = $30
DARK        = $00
NEUTRAL     = $10
LIGHT       = $20
VERY_LIGHT  = $30
GRAY        = $00
BLUE        = $01
INDIGO      = $02
VIOLET      = $03
MAGENTA     = $04
RED         = $05
SALMON      = $06
ORANGE      = $07
YELLOW      = $08
OLIVE       = $09
GREEN       = $0A
TEAL        = $0B
CYAN        = $0C

; VRAM Addresses
NAMETABLE_A = $2000
ATTRTABLE_A = $23C0
NAMETABLE_B = $2400
ATTRTABLE_B = $27C0
NAMETABLE_C = $2800
ATTRTABLE_C = $2BC0
NAMETABLE_D = $2C00
ATTRTABLE_D = $2FC0
BG_COLOR    = $3F00
BG_PAL0     = $3F01
BG_PAL1     = $3F05
BG_PAL2     = $3F09
BG_PAL3     = $3F0D
SPR_PAL0    = $3F11
SPR_PAL1    = $3F15
SPR_PAL2    = $3F19
SPR_PAL3    = $3F1D
