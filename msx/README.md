MSX version
===========

Provides 3 variants:

1. Basic program 32x22 in 15 colors
2. Assembly language program 32x22 in 15 colors
3. Assembly language program 64x44 dithered using 4x4 monochrome chunks

For 32x22 variant program runs in screen mode 1. This mode has 32x24 characters
resolution in 15 colors. A feature of this mode is that the color of characters
tied not to a location on the screen but to character code itself and is defined
for eight consecutive characters simultaneously.

To imitate 8x8 'pixels', 15 color codes for characters 128-255 is redefined in the
way that foreground and background colors of a character are the same. Then character
with appropriate code is put to screen memory. Because foreground and background
colors are the same, characters are seen as color squares.

64x44 variant uses screen mode 2 in a straightforward way.
