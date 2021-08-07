10 print chr$(147)
100 for py=0 to 21
110 for px=0 to 31
120 xz = px*3.5/32-2.5
130 yz = py*2/22-1
140 x = 0
150 y = 0
160 for i=0 to 14
170 if x*x+y*y > 4 then goto 215
180 xt = x*x - y*y + xz
190 y = 2*x*y + yz
200 x = xt
210 next i
215 i = i-1
220 poke 1024+py*40+px,160
230 poke 55296+py*40+px,i
240 next px
260 next py
270 for i=0 to 9
280 print chr$(17)
290 next i
