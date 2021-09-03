10 rem init
20 print chr$(147)
30 scr% = 0
40 col% = 0
50 wdt% = 80
60 clr ti
100 for py%=0 to 21
110 for px%=0 to 31
120 xz = px%*3.5/32-2.5
130 yz = py%*2/22-1
140 x = 0
150 y = 0
160 for i%=0 to 14
170 if x*x+y*y > 4 then goto 220
180 xt = x*x - y*y + xz
190 y = 2*x*y + yz
200 x = xt
210 next i%
220 poke $00800+col%+px%, 160
230 poke $1f800+scr%+px%, i%-1
240 next px%
250 scr%=scr%+wdt%
255 col%=col%+wdt%
260 next py%
265 et = ti
270 print chr$(19);spc(35);"execution time:";et;" seconds"
300 for i%=0 to 20
310 print chr$(17);
320 next i%
