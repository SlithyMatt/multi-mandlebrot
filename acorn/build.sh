#!/bin/sh

ca65 -t bbc -l man2.list bbc-mandelbrot_m2.asm
ld65 -t bbc -o $.BOOT bbc-mandelbrot_m2.o
