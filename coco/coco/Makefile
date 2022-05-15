TGTS=mandelbr.dsk
BASIC=coco12-mandel.bas coco3-mandel.bas

all: $(TGTS)

mandelbr.dsk: $(COCO) $(BASIC)
	decb dskini $@
	decb copy -tb0 coco12-mandel.bas $@,MANDEL1.BAS
	decb copy -tb0 coco3-mandel.bas $@,MANDEL3.BAS
	./decbadd.sh $@ $(COCO)

.PHONY: all

clean:
	rm -f $(COCO) *~ *#

distclean: clean
	rm -f $(TGTS)
