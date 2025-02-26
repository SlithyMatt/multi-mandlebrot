#!/bin/bash

for i in {1,2,4,6,8,12}
do
   echo "Speccy standard, 32x22, 15 max iteration, $i thread"
   gcc -o man_speccy_$i -Ofast -DWIDTH=32 -DHEIGHT=22 -DMAX_ITER=15 -DNUM_THREADS=$i mandelbrot.c -lpthread
done

for i in {1,2,4,6,8,12}
do
   echo "EGA/NTSC standard, 320x200, 16 max iteration, $i thread"
   gcc -o man_ega_$i -Ofast -DWIDTH=320 -DHEIGHT=200 -DMAX_ITER=16 -DNUM_THREADS=$i mandelbrot.c -lpthread
done

for i in {1,2,4,6,8,12,16,24,32,48,64,96,128}
do
   echo "4K UHD, 3840x2160, 2000 max iteration, $i thread"
   gcc -o man_4k_2000_$i -Ofast -DWIDTH=3840 -DHEIGHT=2160 -DMAX_ITER=2000 -DNUM_THREADS=$i mandelbrot.c -lpthread
done
