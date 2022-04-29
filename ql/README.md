Files for Sinclair QL

Assembly language files with ql style names are for QMAC and QLINK
Files with traditional style names are for vasm68k_std and vlink

from ql build using:
- exec_w qmac;'cls'
- exec_w qmac;'mandelbrot'
- exec_w qmac;'plot'
- exec_w qmac;'ql_mandelbrot'
- exec_w qlink;'mandelbrot mandelbrot'

from Linux build using makefile (requires vasmm68k_std and vlink)

If built natively on ql, it should run using: exec_w mandelbrot_bin

If not, then metadata will not be present (or wrong). And file can be run by:
- a=respr(364) : rem 364 is a value >= the length of the binary file
- lbytes mandelbrot_bin,a
- call a

Basic runs in approximately 1:30 and assembly in about 1 sec on stock QL.

Would a QL with a Gold Card (16MHz 68000 be fair?)
