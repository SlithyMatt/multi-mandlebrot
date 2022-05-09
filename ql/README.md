Files for Sinclair QL

Assembly language files with ql style names are for QMAC and QLINK
Files with traditional style names are for vasm68k_std and vlink

from ql build using:
- exec_w qmac;'mandelbrot'
- exec_w qmac;'gfx'
- exec_w qmac;'gfx_mon'
- exec_w qmac;'gfx_raw'
- exec_w qmac;'gfx_tv'
- exec_w qmac;'ql_mandelbrot'
- exec_w qlink;'mandelbrot mandelbrot'
- exec_w qlink;'mandelbrot_mon mandelbrot_mon'
- exec_w qlink;'mandelbrot_raw mandelbrot_raw'
- exec_w qlink;'mandelbrot_tv mandelbrot_tv'

from Linux build using makefile (requires vasmm68k_std and vlink)

Run with
- a=respr(384) : rem 384 is a value >= the length of the binary file
- lbytes mandelbrot_bin,a
- call a

- mandelbrot_bin is lores (32x22), system friendly using QDOS system calls
- mandelbrot_mon_bin is hires (512x256), 4-color, system friendly
  using QDOS sys tem calls
- mandelbrot_raw_bin is lores (32x22), drirectly writing to the screen
- mandelbrot_tv_bin is hires (256x256), 8-color, system friendly using
  QDOS system calls

Basic runs in approximately 1:30 and assembly in about 1 sec on stock QL.

Would a QL with a Gold Card (16MHz 68000 be fair?)
