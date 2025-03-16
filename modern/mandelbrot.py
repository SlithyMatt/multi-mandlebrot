import datetime

start = datetime.datetime.now()

pixels = " .:~÷+<*/([{@%&$"
for py in range(0,22):
    for px in range(0,32):
        xz = px*3.5/32-2.5
        yz = py*2/22-1
        x = 0
        y = 0
        for i in range(0,15):
            if x*x+y*y > 4:
                break
            xt = x*x - y*y + xz
            y = 2*x*y + yz
            x = xt
        print(pixels[i-1],end="")
    print("")
    
delta = datetime.datetime.now() - start
print("Time = " + str(delta.total_seconds()) + " seconds")
