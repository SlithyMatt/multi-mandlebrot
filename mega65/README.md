
# Mandelbrot Benchmark for the MEGA65

This is an adaption of Matts C64 programs to the MEGA65. As the Commander X16, the MEGA65
is a new 8bit computer which reimagines some of the old beauty of those systems using 
more powerful components.

## Platform

The software is tested on xemu MEGA65, using the merger branch (advanced VIC-IV) and a
recently patched original rom (920220 or higher).

## Basic Version

The BASIC65 version is nearly the same as the C64 version. It uses integer (%) variables for
the loops and 24bit POKEs to write to memory (needed for the colour ram located at $1f800).

In addition the RTC of the MEGA65 is used to time the whole mandelbrot loop, so in the end
the time taken is printed to the screen.

It is intended to run in 80x25 text mode, and the timing is printed to thr right of the
"graphic".

## Assembler Version

The assembler version mainly uses the fixedpt routines. I removed the whole conditional part
and made a copy of it, because I needopteded to use acme as assembler.

I decided to use the features available to the 45ce02 cpu, because this is what sets the
different systems apart.

To clear the screen, the dma controller of the MEGA65 is used to clear both screen and colour
ram with a chained dma operation. It also uses the TAB feature to move the base-page to
somewhere else in memory, and then all memory locations in the code use base-page addressing.

To write to the screen and colour ram two 32-bit Base Page Indirect Z-Indexed Mode pointer
are used. I also avoided multiplications in this part, but I don't think that this has a big
impact as the mandelbrot calculations are more prominent in the code.

## ACME Pain

The recommended acme assembler (which support 45CE02 as cpu) is a bit tricky. I was not able
to include the library files in a combined form (defines and macros plus subroutines), this
alsways resulted in "duplicate label" errors. Only splitting the whole thing made it work.

Still investigating...
