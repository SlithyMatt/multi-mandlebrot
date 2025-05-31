Dim pixels(15) as String
pixels(0) = "$"
pixels(1) = "&"
pixels(2) = "%"
pixels(3) = "@"
pixels(4) = "{"
pixels(5) = "["
pixels(6) = "("
pixels(7) = "/"
pixels(8) = "*"
pixels(9) = "<"
pixels(10) = "+"
pixels(11) = "~"
pixels(12) = ":"
pixels(13) = "."
pixels(14) = " "
FOR PY=0 TO 21
   FOR PX=0 TO 31
      XZ = PX*3.5/32-2.5
      YZ = PY*2/22-1
      X = 0
      Y = 0
      FOR I=0 TO 14
         IF X*X+Y*Y > 4 THEN GOTO plotpixel
         XT = X*X - Y*Y + XZ
         Y = 2*X*Y + YZ
         X = XT
      NEXT I
plotpixel:
      LOCATE PY+1,PX*2+1
      PRINT pixels(I)+pixels(I)
   NEXT PX
NEXT PY