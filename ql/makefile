TGTS=mandelbrot_bin mandelbrot_mon_bin mandelbrot_raw_bin mandelbrot_tv_bin 

all: $(TGTS)

mandelbrot_bin: ql_mandelbrot.o mandelbrot.o gfx.o
	vlink -brawbin1 -o $@ $^

mandelbrot_mon_bin: ql_mandelbrot.o mandelbrot.o gfx_mon.o
	vlink -brawbin1 -o $@ $^

mandelbrot_raw_bin: ql_mandelbrot.o mandelbrot.o gfx_raw.o
	vlink -brawbin1 -o $@ $^

mandelbrot_tv_bin: ql_mandelbrot.o mandelbrot.o gfx_tv.o
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
