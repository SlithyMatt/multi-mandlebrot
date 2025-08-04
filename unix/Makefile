CC=cc
CCOPTS=-Wall -Wpedantic

all: mandelbrot xmandelbrot

mandelbrot: mandelbrot.c
	$(CC) $(CCOPTS) -o mandelbrot mandelbrot.c -lcurses

xmandelbrot: xmandelbrot.c
	$(CC) $(CCOPTS) -o xmandelbrot xmandelbrot.c -lX11

clean:
	rm -f *.o
	rm -f mandelbrot
	rm -f xmandelbrot
