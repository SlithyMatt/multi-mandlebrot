#
# Semi universal Makefile for ZX Spectrum projects
# by Andrzej Borsuk
#

# Primary binaries
all:	mand.com mand.hex
clean:
	rm -f *.tap *.hex *.com

# HOWTO compile this stuff:
.SUFFIXES: .asm .bas .as .tap .hex .com

# CP/M executable
.asm.com:
	pasmo --bin $*.asm $*.com
	chmod a+x $*.com

# CP/M hex binary
.asm.hex:
	pasmo --hex $*.asm $*.hex

# ZX Spectrum TAPe for basic program
.bas.tap:
	zmakebas -l -a10 -i10 -n $* -o $*.tap $*.bas
	listbasic $*.tap

# ZX Spectrum ASM program with loader
.asm.tap:
	pasmo --tapbas $*.asm $*.tap
	listbasic $*.tap

# ZX Spectrum ASM without loader
.as.tap:
	pasmo --tap $*.asm $*.tap
