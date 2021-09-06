#!/bin/sh

cl65 -t cx16 -o MAN.PRG -l man.list x16-mandelbrot.asm
cl65 -t cx16 -o MANVGA36.PRG -l manvga46.list x16-mandelbrot-vga36.asm
cl65 -t cx16 -o MAN320.PRG -l manvga46.list x16-mandelbrot-vga320.asm
cl65 -t cx16 -o TEST.PRG -l test.lst -C x16-library.cfg x16-fp24-test.asm
