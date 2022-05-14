TGTS=mandelbr.dsk
BASIC=coco12-mandel.bas coco3-mandel.bas

all: $(TGTS)

mandelbr.dsk: $(COCO) $(BASIC)
	decb dskini $@
	decb copy -tb0 coco12-mandel.bas $@,MANDEL1.BAS
	decb copy -tb0 coco3-mandel.bas $@,MANDEL3.BAS
	decb copy -b2 MAND1L8.BIN $@,MAND1L8.BIN
	decb copy -b2 MAND1L3.BIN $@,MAND1L3.BIN
	decb copy -b2 MAND1H8.BIN $@,MAND1H8.BIN
	decb copy -b2 MAND1H3.BIN $@,MAND1H3.BIN
	decb copy -b2 MAND3L8.BIN $@,MAND3L8.BIN
	decb copy -b2 MAND3L3.BIN $@,MAND3L3.BIN
	decb copy -b2 MAND3H8.BIN $@,MAND3H8.BIN
	decb copy -b2 MAND3H3.BIN $@,MAND3H3.BIN
	decb copy -b2 MANDVL8.BIN $@,MANDVL8.BIN
	decb copy -b2 MANDVL3.BIN $@,MANDVL3.BIN
	decb copy -b2 MANDVH8.BIN $@,MANDVH8.BIN
	decb copy -b2 MANDVH3.BIN $@,MANDVH3.BIN

.PHONY: all

clean:
	rm -f $(COCO) *~ *#

distclean: clean
	rm -f $(TGTS)
