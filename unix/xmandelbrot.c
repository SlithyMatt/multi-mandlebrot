/* 
 * Mandelbrot for X11.
 * Copyright 2025, Andrew C. Young <andrew@vaelen.org>
 * License: MIT
 *
 * To compile: cc -o xmandelbrot xmandelbrot.c -lX11
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <sys/types.h>
#include <sys/times.h>

#define MAX_ITERATIONS 16

char *title = "xmandelbrot";

void get_window_size(display, window, height, width)
     Display *display;
     Window window;
     unsigned int *height;
     unsigned int *width;
{
  Window root;
  int x, y;
  unsigned int border, depth;
  XGetGeometry(display, window, &root, &x, &y, width, height, &border, &depth);
}

unsigned long lookup_color(display, colormap, color_name, color)
     Display *display;
     Colormap colormap;
     char *color_name;
     XColor *color;
{
  XColor exact, screen;
  if (!XAllocNamedColor(display, colormap, color_name, &exact, &screen))
  {
    printf("Color Not Found: %s\n", color_name);
    return 0;
  }
  return screen.pixel;
}

double time_in_seconds()
{
  struct tms buffer;
  clock_t t = times(&buffer);
  return t / 60.0;
}

void calculate(display, window, gc, palette, palette_size)
  Display *display;
  Window window;
  GC gc;
  unsigned long int *palette;
  size_t palette_size;
{
  unsigned int i, col, row, iteration;
  double width, height, x0, y0, x, y, xtemp;
  unsigned int lines, cols;
  unsigned long color;
  double start, finish;

  start = time_in_seconds();
  
  get_window_size(display, window, &lines, &cols);
  height = (double)lines;
  width = (double)cols;

  XClearWindow(display, window);

  for (row = 0; row < lines; row++)
  {
    //    printf("Row: %u\n", row);
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

      i = (iteration % palette_size);
      color = palette[i];
      
      XSetForeground(display, gc, color);
      XDrawPoint(display, window, gc, col, row);
    }
  }

  finish = time_in_seconds();
  printf("Height: %u, Width: %u, Time: %0.3f Seconds\n", lines, cols, (finish-start));

}

int main(argc,argv)
  int argc;
  char **argv;
{
  Display *display;
  Window  window;
 
  GC      gc;
  
  XEvent event;
  KeySym key;
  
  XSizeHints hint;
  
  int screen;
  unsigned long fg, bg;
  int i;
  char text[10];
  int done;

  Colormap colormap;
  
  unsigned long palette[16];
  char *color_names[16];
  color_names[0] = "Black";
  color_names[1] = "DarkBlue";
  color_names[2] = "DarkGreen";
  color_names[3] = "DarkCyan";
  color_names[4] = "DarkRed";
  color_names[5] = "DarkMagenta";
  color_names[6] = "Brown";
  color_names[7] = "LightGray";
  color_names[8] = "Gray";
  color_names[9] = "Blue";
  color_names[10] = "Green";
  color_names[11] = "Cyan";
  color_names[12] = "Red";
  color_names[13] = "Magenta";
  color_names[14] = "Yellow";
  color_names[15] = "White";

  /* setup display/screen */
  display = XOpenDisplay("");
  
  screen = DefaultScreen(display);

  colormap = DefaultColormap(display, screen);

  for (i = 0; i < 16; i++)
  {
    palette[i] = lookup_color(display, colormap, color_names[i]);
  }
  
  /* drawing contexts for an window */
  bg = BlackPixel(display, screen);
  fg = WhitePixel(display, screen);
  hint.x = 100;
  hint.y = 100;
  hint.width = 500;
  hint.height = 300;
  hint.flags = PPosition|PSize;
 
  /* create window */
  window = XCreateSimpleWindow(display, DefaultRootWindow(display),
                                 hint.x, hint.y,
                                 hint.width, hint.height,
                                 5, fg, bg);
 
  /* window manager properties (yes, use of StdProp is obsolete) */
  XSetStandardProperties(display, window, title, title,
                         None, argv, argc, &hint);
 
  /* graphics context */
  gc = XCreateGC(display, window, 0, 0);
  XSetBackground(display, gc, bg);
  XSetForeground(display, gc, fg);
 
  /* allow receiving mouse events */
  XSelectInput(display,window,
               ButtonPressMask|KeyPressMask|ExposureMask);
 
  /* show up window */
  XMapRaised(display, window);
 
  /* event loop */
  done = 0;
  while(done==0){
 
    /* fetch event */
    XNextEvent(display, &event);
 
    switch(event.type){
    case Expose:
      /* Window was showed. */
      if(event.xexpose.count==0)
	calculate(display, window, gc, palette, 16);
      break;
    case MappingNotify:
      /* Modifier key was up/down. */
      XRefreshKeyboardMapping(&event.xmapping);
      break;
    case ButtonPress:
      /* Mouse button was pressed. */
      break;
    case KeyPress:
      /* Key input. */
      i = XLookupString(&event.xkey, text, 10, &key, 0);
      if(i==1 && text[0]=='q') done = 1;
      break;
    }
  }
  
  /* finalization */
  XFreeGC(display,gc);
  XDestroyWindow(display, window);
  XCloseDisplay(display);
 
  exit(0);
}
