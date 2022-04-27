Files for Sinclair QL

Assembly language files with ql style names are for QMAC and QLINK
Files with traditional style names are for vasm68k_std and vlink

from ql build using:
- exec_w qmac;'cls'
- exec_w qmac;'mandeldr'
- exec_w qmac;'mandelpt'
- exec_w qmac;'plot'
- exec_w qlink;'mandel mandel'

from Linux build uging makefile (requires vasmm68k_std and vlink)

If built natively on ql, it should run using: exec_w mandel_bin

If not, then metadata will not be present (or wrong). And file can be run by:
- a=respr(364) : rem 364 is a value >= the length of the binary file
- lbytes mandel_bin,a
- call a

Basic runs in approximately 1:30 and assembly in about 1 sec on stock QL.

Would a QL with a Gold Card (16MHz 68000 be fair?)
