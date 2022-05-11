#define cimg_use_png 1
#include "CImg.h"
#include <array>
#include <chrono>
#include <iostream>

using namespace cimg_library;
using namespace std;

#define WIDTH 1920
#define HEIGHT 1080

int main() {
   auto start = chrono::system_clock::now();
   CImg<unsigned char> img(WIDTH,HEIGHT,1,3,0);

   unsigned char palette[16][3] = { // CGA 16-color palette, as RGB
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

   int px,py,i;
   double xz,yz,x,y,xt;

   for (py=0; py<HEIGHT; py++) {
      for (px=0; px<WIDTH; px++) {
         xz = (double)px*3.5/WIDTH-2.5;
         yz = (double)py*2.0/HEIGHT-1.0;
         x = 0.0;
         y = 0.0;
         for (i=0; i<15; i++) {
            if (x*x+y*y > 4) {
               break;
            }
            xt = x*x - y*y + xz;
            y = 2*x*y + yz;
            x = xt;
         }
         if (i > 14) {
            i = 0;
         }
         img(px,py,0,0) = palette[i][0]; // R
         img(px,py,0,1) = palette[i][1]; // G
         img(px,py,0,2) = palette[i][2]; // B
      }
   }

   img.save_png("mandelbrot.png");

   auto end = chrono::system_clock::now();

   cout << "Elapsed Time: " << (end-start).count()/(double)chrono::system_clock::duration::period::den << "s" << endl;

   return 0;
}
