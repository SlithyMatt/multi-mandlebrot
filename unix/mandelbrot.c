/*
 * Mandelbrot for UNIX.
 * Copyright 2025, Andrew C. Young <andrew@vaelen.org>
 * License: MIT
 *
 * This program was written on a Macintosh Quadra 700 running A/UX 3.1.
 * A/UX was Apple's first version of UNIX, based on both SYSV and BSD.
 * A/UX 3.1 was released in 1994, and its default C compiler did not
 * yet support the ANSI standard. As such, this program is written to
 * work with earlier K&R versions of C. It should also compile with GCC.
 *
 * It uses the curses library for screen manipulation, but it should
 * also work with the later ncurses library.
 *
 * My classic Mac resources can be found at m68k.club (www,gopher).
 */

#include <stdlib.h>
#include <string.h>

/* Used to write to the screen */
#include <curses.h>

/* Used to measure run time */
#include <sys/types.h>
#include <sys/times.h>

#define MAX_ITERATIONS 16

int *pixels = 0;
int cols = 80;
int lines = 24;

char symbols[] = {' ','-','+','=','\\','|','/','*',
                  '#','3','8','B','=','#','+','.'};

char *header = "[ Mandelbrot by Andrew C. Young ]";
char *footer = "[ Press Any Key to Exit ]";

WINDOW *win = 0;

void init()
{
  initscr();
  nonl(); 
  cbreak(); 
  noecho();

  /* Draw Box */
  wmove(stdscr,0,0);
  wclear(stdscr);
  box(stdscr,'|','-');
  wmove(stdscr,0,0);
  waddch(stdscr, '+');
  wmove(stdscr,0,COLS-1);
  waddch(stdscr, '+');
  wmove(stdscr,LINES-1,0);
  waddch(stdscr, '+');
  wmove(stdscr,LINES-1,COLS-1);
  waddch(stdscr, '+');
  wmove(stdscr,0,( (COLS/2) - (strlen(header)/2) -1 ) );
  waddstr(stdscr, header);
  wrefresh(stdscr);

  lines = LINES - 2;
  cols = COLS - 2;
  win = newwin(lines,cols,1,1);
  pixels = (int*)malloc(cols*lines*sizeof(int));
}

void cleanup()
{
  if (pixels != 0)
  {
    free(pixels);
  }
  endwin();
}

void calculate()
{
  int i, col, row, iteration;
  double width, height, x0, y0, x, y, x_scale, y_scale, xtemp;

  width = (double)cols;
  height = (double)lines;

  i = 0;

  for (row = 0; row < lines; row++)
  {
    y0 = (row * 2.1 / height) - 1;
    for (col = 0; col < cols; col++)
    {
      x0 = (col * 3.5 / width) - 2.5;
      x = 0.0;
      y = 0.0;
      iteration = 0;
      while ( ((x*x) + (y*y) <= 4) && (iteration < MAX_ITERATIONS))
      {
        xtemp = (x*x) - (y*y) + x0;
        y = (2*x*y) + y0;
        x = xtemp;
        iteration++;
      }

      /* printf("%X",iteration); */
      pixels[i] = iteration;
      i++;
    }
  }
}

void display()
{
  int i, col, row;
  int value;
  int color;
  char symbol;

  /* Clear the screen */
  wmove(win,0,0);
  wclear(win);

  i = 0;

  for (row = 0; row < lines; row++)
  {
    wmove(win,row,0);
    for (col = 0; col < cols; col++)
    {
      value = pixels[i];
      value = value % 16;
      symbol = symbols[value];
      waddch(win,symbol);
      i++;
    }
  }
  wrefresh(win);
}

void pause()
{
  wmove(stdscr,LINES-1,( (COLS/2) - (strlen(footer)/2) -1 ) );
  waddstr(stdscr, footer);
  wmove(stdscr,LINES-1,COLS-1);
  wrefresh(stdscr);
  getchar();
}

double time_in_seconds()
{
  struct tms buffer;
  clock_t t = times(&buffer);
  return t / 60.0;
}

void main()
{
  double start, after_calc, after_display, calc_time, display_time;

  init();
  start = time_in_seconds();
  calculate();
  after_calc = time_in_seconds();
  display();
  after_display = time_in_seconds();
  pause();
  cleanup();

  calc_time = (after_calc - start); 
  display_time = (after_display - after_calc); 

  printf("\nCalculation Time: %0.3f secs, Display Time: %0.3f secs, Total Time: %0.3f secs\n", calc_time, display_time, calc_time + display_time);

  exit(0);
}
