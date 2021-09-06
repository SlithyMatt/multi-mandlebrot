10 rem init
20 print chr$(147)
30 scr% = 0
40 col% = 0
50 wdt% = 80
60 rem reset rtc timer
70 clr ti
90 rem mandelbrot loop
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
220 poke $00800+col%+px%+px%, 160
230 poke $00801+col%+px%+px%, 160
240 poke $1f800+scr%+px%+px%, i%-1
250 poke $1f801+scr%+px%+px%, i%-1
260 next px%
270 scr%=scr%+wdt%
280 col%=col%+wdt%
290 next py%
300 et = ti : rem save execution time
310 cursor on,65,1:print"exec. time:"
320 cursor on,65,2:print et
330 cursor on,65,3:print"seconds"
340 cursor on,1,21