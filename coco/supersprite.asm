	ifdef MPI
ssbase	equ $ff50
mpireg	equ $ff7f
	else
ssbase	equ $ff70
	endif
reg2413	equ ssbase+$06
dat2413	equ ssbase+$07
vram	equ ssbase+$08
vidreg	equ ssbase+$09
vidpal	equ ssbase+$0a
vidind	equ ssbase+$0b
reg2149	equ ssbase+$0c
dat2149	equ ssbase+$0d
vidmux	equ ssbase+$0e
