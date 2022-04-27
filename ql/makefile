TGTS=mandel_bin null_bin

all: $(TGTS)

mandel_bin: mandeldr.o cls.o mandelpt.o plot.o
	vlink -brawbin1 -o $@ $^

null_bin: mandeldr.o cls.o nullpt.o plot.o
	vlink -brawbin1 -o $@ $^

%.o: %.asm
	vasmm68k_std -Felf -o $@ $<

mandelpt.o: ../68000/mandelpt.asm
	vasmm68k_std -Felf -o $@ $<

.PHONY: all clean distclean

clean:
	rm -Rf *.o *~ $#

distclean: clean
	rm -Rf $(TGTS)
