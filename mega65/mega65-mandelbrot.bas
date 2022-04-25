10 rem init
20 print chr$(147)
30 scr% = 0
40 wdt% = 80
50 rem reset rtc timer
60 clr ti
70 rem mandelbrot loop
80 for py%=0 to 21
90 for px%=0 to 31
100 xz = px%*3.5/32-2.5
110 yz = py%*2/22-1
120 x = 0
130 y = 0
140 for i%=0 to 14
150 if x*x+y*y > 4 then goto 200
160 xt = x*x - y*y + xz
170 y = 2*x*y + yz
180 x = xt
190 next i%
200 dx% = px%+px%
210 poke $1f800+scr%+dx%, i%-1
220 poke $1f801+scr%+dx%, i%-1
230 poke $00800+scr%+dx%, 160
240 poke $00801+scr%+dx%, 160
250 next px%
260 scr%=scr%+wdt%
270 next py%
280 et = ti : rem save execution time
290 cursor on,65,1:print"exec. time:"
300 cursor on,65,2:print et
310 cursor on,65,3:print"seconds"
320 cursor on,1,21