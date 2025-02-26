#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>

#ifndef WIDTH
#define WIDTH 3840
#endif

#ifndef HEIGHT
#define HEIGHT 2160
#endif

#ifndef MAX_ITER
#define MAX_ITER 2000
#endif

#ifndef NUM_THREADS
#define NUM_THREADS 12
#endif

#if NUM_THREADS > HEIGHT
#error "Can't have more threads than pixel rows!"
#endif

void set_pixel(unsigned char *img, int x, int y, unsigned char *color);
unsigned char *create_image(int w, int h);
void write_ppm(char *name, int w, int h, unsigned char *img);

unsigned char **palette;

unsigned char cga_palette[16][3] = { // CGA 16-color palette, as RGB
  {0x00,0x00,0x00},
  {0x00,0x00,0xAA},
  {0x00,0xAA,0x00},
  {0x00,0xAA,0xAA},
  {0xAA,0x00,0x00},
  {0xAA,0x00,0xAA},
  {0xAA,0x55,0x00},
  {0xAA,0xAA,0xAA},
  {0x55,0x55,0x55},
  {0x55,0x55,0xFF},
  {0x55,0xFF,0x55},
  {0x55,0xFF,0xFF},
  {0xFF,0x55,0x55},
  {0xFF,0x55,0xFF},
  {0xFF,0xFF,0x55},
  {0xFF,0xFF,0xFF}
};

int next_row=0;
pthread_mutex_t lock;
unsigned char *img;

void dorow(int py) {
  int px,i;
  double xz,yz,x,y,xt;

  for (px=0; px<WIDTH; px++) {
    xz = (double)px*3.5/WIDTH-2.5;
    yz = (double)py*2.0/HEIGHT-1.0;
    x = 0.0;
    y = 0.0;
    for (i=0; i<MAX_ITER; i++) {
      if (x*x+y*y > 4) {
	break;
      }
      xt = x*x - y*y + xz;
      y = 2*x*y + yz;
      x = xt;
    }
    if (i >= MAX_ITER) {
      i = 0;
    }
    set_pixel(img, px, py, palette[i]);
  }
}

void *rowthread(void *v) {
  int row;
  
  for(;;) {
    pthread_mutex_lock(&lock);
    row=next_row++;
    pthread_mutex_unlock(&lock);
    if(row>=HEIGHT) break;
    dorow(row);
  }    
}

int main() {
  double start, end;
  struct timespec tspec;
  int py,i;
  pthread_t rowthreads[NUM_THREADS-1];

  img = create_image(WIDTH, HEIGHT);
  palette=malloc(MAX_ITER*sizeof(unsigned char *));
  for (int j=0; j<MAX_ITER; j++) palette[j]=malloc(3*sizeof(unsigned char));
  clock_gettime(CLOCK_REALTIME, &tspec);
  start = tspec.tv_sec+1e-9*tspec.tv_nsec;

  for (i=0; i<MAX_ITER; i++) {
    if (i<16) {
      palette[i][0] = cga_palette[i][0];
      palette[i][1] = cga_palette[i][1];
      palette[i][2] = cga_palette[i][2];
    } else if (i % 16 == 0) {
      palette[i][0] = i & 0x10 ? 255 : 0;
      palette[i][1] = i & 0x20 ? 255 : 0;
      palette[i][2] = i & 0x40 ? 255 : 0;
      if ((i & 0x70) == 0) {
	palette[i][0] = 255;
	palette[i][1] = 128;            
      }
    } else {
      palette[i][0] = palette[i-1][0] > 16 ? palette[i-1][0] - 16 : 0;
      palette[i][1] = palette[i-1][1] > 16 ? palette[i-1][1] - 16 : 0;
      palette[i][2] = palette[i-1][2] > 16 ? palette[i-1][2] - 16 : 0;
    }
  }

  for (i=0; i<NUM_THREADS-1; i++)
    pthread_create(rowthreads+i, NULL, rowthread, NULL);
  rowthread(NULL);
  for(i=0; i<NUM_THREADS-1; i++) pthread_join(rowthreads[i], NULL);

  
  write_ppm("mandelbrot.ppm", WIDTH, HEIGHT, img);

  clock_gettime(CLOCK_REALTIME, &tspec);
  end = tspec.tv_sec+1e-9*tspec.tv_nsec;

  printf("Elapsed Time: %f s\n", end-start);

  return 0;
}

unsigned char *create_image(int w, int h) {
  unsigned char *rv;
    
  return rv = malloc(w*h*3);
}

void set_pixel(unsigned char *img, int x, int y, unsigned char *color) {
  img[3*(x+y*WIDTH)+0] = color[0]; // Red
  img[3*(x+y*WIDTH)+1] = color[1]; // Green
  img[3*(x+y*WIDTH)+2] = color[2]; // Blue
}

void write_ppm(char *name, int w, int h, unsigned char *img) {
  FILE *out;

  if (!(out=fopen(name, "w"))) {
    fprintf(stderr, "Unable to open %s for writing\n", name);
    return;
  }
  fprintf(out, "P6\n%d %d\n255\n", WIDTH, HEIGHT);
  fwrite(img, 3, w*h, out);
  fclose(out);
}
    
