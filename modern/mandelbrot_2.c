#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <getopt.h>
#include <errno.h>

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

unsigned char *create_image(int w, int h);
void help(FILE *);
void set_pixel(unsigned char *img, int x, int y, unsigned char *color);
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
int width=WIDTH;
int height=HEIGHT;
int max_iter=MAX_ITER;
int num_threads=NUM_THREADS;

void dorow(int py) {
  int px,i;
  double xz,yz,x,y,xt;

  for (px=0; px<width; px++) {
    xz = (double)px*3.5/width-2.5;
    yz = (double)py*2.0/height-1.0;
    x = 0.0;
    y = 0.0;
    for (i=0; i<max_iter; i++) {
      if (x*x+y*y > 4) {
	break;
      }
      xt = x*x - y*y + xz;
      y = 2*x*y + yz;
      x = xt;
    }
    if (i >= max_iter) {
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
    if(row>=height) break;
    dorow(row);
  }    
}

int main(int argc, char *argv[]) {
  double start, end;
  struct timespec tspec;
  int py,i, opt;
  pthread_t *rowthreads;
  char opts[]="h:i:o:t:w:?";
  struct option long_opts[] = {
    { "height", 1, NULL, 'h'},
    { "width", 1, NULL, 'w'},
    { "iterations", 1, NULL, 'i'},
    { "max_iter", 1, NULL, 'i'},
    { "out", 1, NULL, 'o'},
    { "threads", 1, NULL, 't'},
    { "num_threads", 1, NULL, 't'},
    { "help", 0, NULL, '?'},
    { NULL, 0, NULL, '\0'}
  };
  char *outname="mandelbrot.ppm";
  
  while((opt=getopt_long(argc, argv, opts, long_opts, NULL))!=-1) {
    switch(opt) {
    case 'h':
      errno = 0;
      height = strtol(optarg, NULL, 10);
      if (errno || height<=0) {
	fprintf(stderr, "Invalid height: %s\n", optarg);
	return -1;
      }
      break;
    case 'i':
      errno = 0;
      max_iter = strtol(optarg, NULL, 10);
      if (errno || max_iter<=0) {
	fprintf(stderr, "Invalid number of iterations: %s\n", optarg);
	return -1;
      }
      break;
    case 'w':
      errno = 0;
      width = strtol(optarg, NULL, 10);
      if (errno || width<=0) {
	fprintf(stderr, "Invalid width: %s\n", optarg);
	return -1;
      }
      break;
    case 't':
      errno = 0;
      num_threads = strtol(optarg, NULL, 10);
      if (errno || num_threads<=0) {
	fprintf(stderr, "Invalid number of threads: %s\n", optarg);
	return -1;
      }
      break;
    case 'o':
      outname=optarg;
      break;
    default:
      help(stdout);
    }
  }
  if (num_threads>height) {
    fprintf(stderr, "Number of threads (%d) cannot be greater than height (%d)\n", num_threads, height);
    return -1;
  }
  
  rowthreads = malloc(sizeof(pthread_t)*num_threads);
  img = create_image(width, height);
  palette=malloc(max_iter*sizeof(unsigned char *));
  for (int j=0; j<max_iter; j++) palette[j]=malloc(3*sizeof(unsigned char));
  clock_gettime(CLOCK_REALTIME, &tspec);
  start = tspec.tv_sec+1e-9*tspec.tv_nsec;

  for (i=0; i<max_iter; i++) {
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

  for (i=0; i<num_threads-1; i++)
    pthread_create(rowthreads+i, NULL, rowthread, NULL);
  rowthread(NULL);
  for(i=0; i<num_threads-1; i++) pthread_join(rowthreads[i], NULL);

  write_ppm(outname, width, height, img);

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
  img[3*(x+y*width)+0] = color[0]; // Red
  img[3*(x+y*width)+1] = color[1]; // Green
  img[3*(x+y*width)+2] = color[2]; // Blue
}

void write_ppm(char *name, int w, int h, unsigned char *img) {
  FILE *out;

  if (!(out=fopen(name, "w"))) {
    fprintf(stderr, "Unable to open %s for writing\n", name);
    return;
  }
  fprintf(out, "P6\n%d %d\n255\n", width, height);
  fwrite(img, 3, w*h, out);
  fclose(out);
}

void help(FILE *out) {
  fprintf(out, "Usage: mandelbrot <options>\n");
  fprintf(out, "\t-w\t--width\t\tImage width (%d)\n", width);
  fprintf(out, "\t-h\t--height\tImage height (%d)\n", height);
  fprintf(out, "\t-i\t--iterations\tMaximum number of iterations (%d)\n", max_iter);
  fprintf(out, "\t-t\t--threads\tNumber of threads (%d)\n", num_threads);
  fprintf(out, "\t-o\t--out\t\tOutput name (mandelbrot.ppm)\n");
  if (out==stdout) exit(0);
  exit(-1);
}

    
