#!/bin/sh

acme -r man.list mega65-mandelbrot.asm

# create disk image
cbmconvert -D8o MAN65.D81 -n man.prg
