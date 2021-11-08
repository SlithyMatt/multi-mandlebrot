10 rem init graphics 320x200x8
20 graphic clr
30 screen def 1,0,0,8
40 screen open 1
50 screen set 1,1
80 scnclr 0
90 gosub 1000 : rem or 2000 for commander x16
100 rem reset rtc timer
110 clr ti
120 rem mandelbrot loop only 320x200
121 dx=3.5/320
122 dy=2.625/200
124 yc=-1.3125
130 for py=0 to 199
135 xc=-2.5
140 for px=0 to 319
170 x=xc:y=yc:i=1 : REM first iteration...
180 xx = x*x
181 yy = y*y
190 if xx+yy>4 then goto 250
200 xt=xx-yy+xc
210 y=2*x*y+yc
220 x=xt
230 i=i+1
240 if i<48 then goto 180
250 pen 0,i+80
260 line px,py
265 xc=xc+dx
270 next px
275 yc=yc+dy
280 next py
300 et = ti : rem save execution time
310 getkey a$ : rem wait for keypress
320 screen close 1
330 print et
340 end
1000 rem generate custom palette
1010 palette 1,0,0,0,0
1010 for r=0 to 2
1020 for g=0 to 3
1030 for b=0 to 3
1040 palette 1,81+r*16+g*4+b,14-r*5,14-g*3,14-b*3
1050 next b,g,r
1060 rem max iterations black
1070 palette 1,128,0,0,0
1080 return
2000 rem set commander x16 palette
2001 palette 1,81,2,1,0
2002 palette 1,82,4,3,0
2003 palette 1,83,6,4,0
2004 palette 1,84,8,6,0
2005 palette 1,85,10,8,0
2006 palette 1,86,12,9,0
2007 palette 1,87,15,11,0
2008 palette 1,88,1,2,1
2009 palette 1,89,3,4,3
2010 palette 1,90,5,6,4
2011 palette 1,91,7,8,6
2012 palette 1,92,9,10,8
2013 palette 1,93,11,12,9
2014 palette 1,94,13,15,11
2015 palette 1,95,1,2,1
2016 palette 1,96,3,4,2
2017 palette 1,97,4,6,3
2018 palette 1,98,6,8,4
2019 palette 1,99,8,10,5
2020 palette 1,100,9,12,6
2021 palette 1,101,11,15,7
2022 palette 1,102,1,2,0
2023 palette 1,103,2,4,1
2024 palette 1,104,4,6,1
2025 palette 1,105,5,8,2
2026 palette 1,106,6,10,2
2027 palette 1,107,8,12,3
2028 palette 1,108,9,15,3
2029 palette 1,109,1,2,0
2030 palette 1,110,2,4,0
2031 palette 1,111,3,6,0
2032 palette 1,112,4,8,0
2033 palette 1,113,5,10,0
2034 palette 1,114,6,12,0
2035 palette 1,115,7,15,0
2036 palette 1,116,1,2,1
2037 palette 1,117,3,4,3
2038 palette 1,118,4,6,5
2039 palette 1,119,6,8,6
2040 palette 1,120,8,10,8
2041 palette 1,121,9,12,10
2042 palette 1,122,11,15,12
2043 palette 1,123,1,2,1
2044 palette 1,124,2,4,2
2045 palette 1,125,3,6,4
2046 palette 1,126,4,8,5
2047 palette 1,127,5,10,6
2048 rem max iterations black
2049 palette 1,128,0,0,0
2050 return