TGTS=mandelbrot_bin null_bin

all: $(TGTS)

mandelbrot_bin: ql-mandelbrot.o cls.o mandelbrot.o plot.o
	vlink -brawbin1 -o $@ $^

null_bin: ql-mandelbrot.o cls.o nullpt.o plot.o
	vlink -brawbin1 -o $@ $^

%.o: %.asm
	vasmm68k_std -Felf -o $@ $<

mandelbrot.o: ../68000/mandelbrot.asm
	vasmm68k_std -Felf -o $@ $<

.PHONY: all clean distclean

clean:
	rm -Rf *.o *~ $#

distclean: clean
	rm -Rf $(TGTS)
