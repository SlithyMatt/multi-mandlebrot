10  MODE 2: CLS
30 FOR I% = 0 TO 47
40   R% = I% / 16
50   R% = R% * 85
60   G% = (I% AND 15) / 4
70   G% = G% * 85
80   B% = I% AND 3
90   B% = B% * 85
100  VDU 23,27,0,I%
110  VDU 23,27,1,1;1;R%,G%,B%,255
120 NEXT I%
130  FOR PY%=0 TO 199
140    YZ = PY%*2.625/200-1.3125
150    FOR PX%=0 TO 319
160      XZ = PX%*3.5/320-2.5
170      X = 0: Y = 0
180      FOR I%=0 TO 47
190        IF X*X+Y*Y > 4 THEN GOTO 240
200       XT=X*X-Y*Y+XZ
210       Y=2*X*Y+YZ
220       X=XT
230     NEXT I%
240     VDU 23,27,0,I%
250     VDU 23,27,3,PX%;PY%;
260   NEXT PX%
270 NEXT PY%
280 T$=GET$
290 MODE 1: COLOUR 3
