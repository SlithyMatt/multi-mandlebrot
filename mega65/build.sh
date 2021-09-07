#!/bin/sh

acme -r man.list mega65-mandelbrot.asm

## create disk image with man.prg
#cbmconvert -D8o MAN65.D81 -n man.prg

# add man.prg to test disk
c1541 -attach ~/nextCloud/stuff/Hardware/mega65/disks/M65MAN.D81 -delete man65asm -write man.prg man65asm
