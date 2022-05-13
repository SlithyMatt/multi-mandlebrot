#define cimg_use_png 1
#include "CImg.h"
#include <array>
#include <atomic>
#include <chrono>
#include <iostream>
#include <queue>
#include <thread>

using namespace cimg_library;
using namespace std;

#define WIDTH 3840
#define HEIGHT 2160
#define MAX_ITER 2000
#define NUM_THREADS 12

#if NUM_THREADS > HEIGHT
#error "Can't have more threads than pixel rows!"
#endif

CImg<unsigned char> img(WIDTH,HEIGHT,1,3,0);

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

array<array<unsigned char,3>,MAX_ITER> palette;

atomic<int> active_threads(0);

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
      img(px,py,0,0) = palette[i][0]; // R
      img(px,py,0,1) = palette[i][1]; // G
      img(px,py,0,2) = palette[i][2]; // B
   }

   active_threads--;
}

int main() {
   auto start = chrono::system_clock::now();

   int py,i;
   array<thread *,NUM_THREADS> rowthreads;
   queue<int> rowq;

   for (i=0; i<MAX_ITER; i++) {
      if (i<16) {
         palette[i][0] = cga_palette[i][0];
         palette[i][1] = cga_palette[i][1];
         palette[i][2] = cga_palette[i][2];
      } else if (i % 16 == 0) {
         palette[i][0] = i & 0x10 ? 255 : 0;
         palette[i][1] = i & 0x20 ? 255 : 0;
         palette[i][2] = i & 0x40 ? 255 : 0;
      } else {
         palette[i][0] = palette[i-1][0] > 8 ? palette[i-1][0] - 8 : 0;
         palette[i][1] = palette[i-1][1] > 8 ? palette[i-1][1] - 8 : 0;
         palette[i][2] = palette[i-1][2] > 8 ? palette[i-1][2] - 8 : 0;
      }
   }

   for (i=0; i<NUM_THREADS; i++) {
      rowthreads[i] = NULL;
   }

   for (py=0; py<HEIGHT; py++) {
      rowq.push(py);
   }

   while (rowq.size() > 0) {
      for (i=0; i<NUM_THREADS; i++) {
         if ((rowthreads[i] == NULL) || rowthreads[i]->joinable()) {
            if (rowthreads[i] != NULL) {
               rowthreads[i]->join();
               delete rowthreads[i];
            }
            if (rowq.size() > 0) {
               py = rowq.front();
               rowq.pop();
               active_threads++;
               rowthreads[i] = new thread(dorow,py);
            }
         }
      }
   }

   while (active_threads > 0);

   img.save_png("mandelbrot.png");

   auto end = chrono::system_clock::now();

   cout << "Elapsed Time: " << (end-start).count()/(double)chrono::system_clock::duration::period::den << "s" << endl;

   return 0;
}
