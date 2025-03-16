OPTS=-Ofast
LIBS=-lpthread

all: mandelbrot

mandelbrot: mandelbrot_2.c
	$(CC) $(OPTS) -o $@ $^ $(LIBS)

.PHONY: clean distclean

clean:
	rm -f *~ *.o *# *.ppm

distclean: clean
	rm -f mandelbrot
