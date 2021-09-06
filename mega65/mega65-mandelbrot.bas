10 rem init
20 print chr$(147)
30 scr% = 0
40 col% = 0
50 wdt% = 80
60 rem reset rtc timer
70 clr ti
80 rem mandelbrot loop
90 for py%=0 to 21
100 for px%=0 to 31
110 xz = px%*3.5/32-2.5
120 yz = py%*2/22-1
130 x = 0
140 y = 0
150 for i%=0 to 14
160 if x*x+y*y > 4 then goto 210
170 xt = x*x - y*y + xz
180 y = 2*x*y + yz
190 x = xt
200 next i%
210 dx% = px%+px%
220 poke $1f800+scr%+dx%, i%-1
230 poke $1f801+scr%+dx%, i%-1
240 poke $00800+col%+dx%, 160
250 poke $00801+col%+dx%, 160
260 next px%
270 scr%=scr%+wdt%
280 col%=col%+wdt%
290 next py%
300 et = ti : rem save execution time
310 cursor on,65,1:print"exec. time:"
320 cursor on,65,2:print et
330 cursor on,65,3:print"seconds"
340 cursor on,1,21