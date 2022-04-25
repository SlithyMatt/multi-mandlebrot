#!/usr/bin/python

from PIL import Image, ImageDraw

MAX_ITER = 80

def mandelbrot(c):
    z = c
    n = 1
    max_r, max_i = 0.0, 0.0
    while abs(z) <= 2 and n < MAX_ITER:
        z = z*z + c
        max_r = max(max_r, abs(z.real))
        max_i = max(max_i, abs(z.imag))
        n += 1
    return n, max_r, max_i

# Image size (pixels)
WIDTH = 600
HEIGHT = 400

# Plot window
RE_START = -2.5
RE_END = 1
IM_START = -1.3125
IM_END = 1.3125

palette = []

im = Image.new('RGB', (WIDTH, HEIGHT), (0, 0, 0))
draw = ImageDraw.Draw(im)

mmr, mmi = 0.0, 0.0
for x in range(0, WIDTH):
    for y in range(0, HEIGHT):
        # Convert pixel coordinate to complex number
        c = complex(RE_START + (x / WIDTH) * (RE_END - RE_START),
                    IM_START + (y / HEIGHT) * (IM_END - IM_START))
        # Compute the number of iterations
        m, mr, mi = mandelbrot(c)
        mmr = max(mmr, mr)
        mmi = max(mmi, mi)
        # The color depends on the number of iterations
        color = 255 - int(m * 255 / MAX_ITER)
        # Plot the point
        draw.point([x, y], (color, color, color))

print(mmr, mmi)
im.save('output.png', 'PNG')
