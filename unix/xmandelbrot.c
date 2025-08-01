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
#include <unistd.h>

char *title = "xmandelbrot";

struct color {
  unsigned char r, g, b;
};

struct color colors_1bit[2];
struct color colors_2bit[4];
struct color colors_4bit[16];
struct color colors_8bit[256];

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

unsigned long lookup_color(display, colormap, color)
     Display *display;
     Colormap colormap;
     struct color color;
{
  XColor screen;

  /* Convert our 8-bit color space into a 16-bit color space */
  screen.red = (color.r << 8) | color.r;
  screen.green = (color.g << 8) | color.g;
  screen.blue = (color.b << 8) | color.b;

  if (!XAllocColor(display, colormap, &screen))
  {
    printf("Color Not Found: rgb:%02x/%02x/%02x\n", color.r, color.g, color.b);
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
    //    printf("Row: %u\n", row);q
    y0 = (row * 2.1 / height) - 1;
    for (col = 0; col < cols; col++)
    {
      x0 = (col * 3.5 / width) - 2.5;
      x = 0.0;
      y = 0.0;
      iteration = 0;
      while ( ((x*x) + (y*y) <= 4) && (iteration < palette_size) )
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

struct color color(r, g, b)
  unsigned char r, g, b;
{
  struct color c;
  c.r = r;
  c.g = g;
  c.b = b;
  return c;
}

void initialize_colors()
{
  int steps[16];
  int idx, i, j, v, r, g, b;

  /* Macintosh System 7 1-bit palette (Black, White) */
  colors_1bit[0] = color(0x00, 0x00, 0x00);
  colors_1bit[1] = color(0xff, 0xff, 0xff);

  /* Macintosh System 7 2-bit palette */
  colors_2bit[0] = color(0x00, 0x00, 0x00);
  colors_2bit[1] = color(0x44, 0x44, 0x44);
  colors_2bit[2] = color(0xbb, 0xbb, 0xbb);
  colors_2bit[3] = color(0xff, 0xff, 0xff);

  /* Macintosh System 7 4-bit palette (16 colors, XLib rgb format) */
  colors_4bit[0]  = color(0x00, 0x00, 0x00);
  colors_4bit[1]  = color(0x88, 0x00, 0x00);
  colors_4bit[2]  = color(0x00, 0x88, 0x00);
  colors_4bit[3]  = color(0x00, 0x00, 0x88);
  colors_4bit[4]  = color(0x88, 0x88, 0x00);
  colors_4bit[5]  = color(0x00, 0x88, 0x88);
  colors_4bit[6]  = color(0x88, 0x00, 0x88);
  colors_4bit[7]  = color(0x44, 0x44, 0x44);
  colors_4bit[8]  = color(0xbb, 0xbb, 0xbb);
  colors_4bit[9]  = color(0xff, 0x88, 0x88);
  colors_4bit[10] = color(0x88, 0xff, 0x88);
  colors_4bit[11] = color(0x88, 0x88, 0xff);
  colors_4bit[12] = color(0xff, 0xff, 0x88);
  colors_4bit[13] = color(0x88, 0xff, 0xff);
  colors_4bit[14] = color(0xff, 0x88, 0xff);
  colors_4bit[15] = color(0xff, 0xff, 0xff);

  /* Macintosh 8-bit system palette (from lospec.com, 256 colors) */
  idx = 0;
  
  steps[0] = 0x00;
  steps[1] = 0x0b;
  steps[2] = 0x22;
  steps[3] = 0x44;
  steps[4] = 0x55;
  steps[5] = 0x77;
  steps[6] = 0x88;
  steps[7] = 0xaa;
  steps[8] = 0xbb;
  steps[9] = 0xdd;
  steps[10] = 0xee;
  steps[11] = 0x33;
  steps[12] = 0x66;
  steps[13] = 0x99;
  steps[14] = 0xcc;
  steps[15] = 0xff;

  /* grayscale */
  for (i = 0; i < 11; i++) 
  {
    v = steps[i];
    colors_8bit[idx++] = color(v, v, v);
  }

  /* 10 blue, 10 green, 10 red */
  for (j = 0; j < 3; j++)
  {
    for (i = 1; i < 11; i++) 
    {
      v = steps[i];
      switch (j)
      {
        case 0: colors_8bit[idx++] = color(0x00, 0x00, v); break; /* blue */
        case 1: colors_8bit[idx++] = color(0x00, v, 0x00); break; /* green */
        case 2: colors_8bit[idx++] = color(v, 0x00, 0x00); break; /* red */
      }
    }
  }

  /* the rest */
  for (r = 10; r < 16; r++)
  {
    for (g = 10; g < 16; g++)
    {
      for (b = 10; b < 16; b++)
      {
        if (r == 10 && g == 10 && b == 10) continue; /* skip black */
        colors_8bit[idx++] = color(steps[r == 10 ? 0 : r], steps[g == 10 ? 0 : g], steps[b == 10 ? 0 : b]);
      }
    }
  }

  printf("Initialized %u colors.\n", idx);

}

void create_palette(display, colormap, palette, colors, size)
     Display *display;
     Colormap colormap;
     unsigned long *palette;
     struct color *colors;
     size_t size;
{
  size_t i;
  for (i = 0; i < size; i++)
  {
    palette[i] = lookup_color(display, colormap, colors[i]);
  }
}

int main(argc,argv)
  int argc;
  char **argv;
{

  /* X11 variables */

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
  unsigned int width, height, lastWidth, lastHeight;
  struct color *colors = colors_8bit;
  Colormap colormap;
  
  unsigned long palette[256];

  int max_iterations = 256;
  if (argc > 1)
  {
    max_iterations = atoi(argv[1]);
    if (max_iterations < 1 || max_iterations > 256)
    {
      fprintf(stderr, "Usage: %s [max_iterations (1-256)]\n", argv[0]);
      exit(1);
    }
  }
  initialize_colors();

  /* setup display/screen */
  display = XOpenDisplay("");
  if (!display) {
    fprintf(stderr, "Error: Unable to open display\n");
    exit(1);
  }

  screen = DefaultScreen(display);

  colormap = DefaultColormap(display, screen);

  if (max_iterations < 1 || max_iterations > 256)
  {
    fprintf(stderr, "Error: max_iterations must be between 1 and 256\n");
    exit(1);
  }

  if (max_iterations <= 2)
    colors = colors_1bit;
  else if (max_iterations <= 4)
    colors = colors_2bit;
  else if (max_iterations <= 16)
    colors = colors_4bit;
  else
    colors = colors_8bit;

  create_palette(display, colormap, palette, colors, max_iterations);

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
      /* Window was shown. */
      if(event.xexpose.count == 0)
      {
        get_window_size(display, window, &height, &width);
        if (width != lastWidth || height != lastHeight)
        {
          calculate(display, window, gc, palette, max_iterations);
        }
        lastWidth = width;
        lastHeight = height;
      }
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
