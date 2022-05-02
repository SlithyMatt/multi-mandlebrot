TGTS=mandelbr.dsk mandelbr.vdk
SPT=../6x09/mandelbrot.asm ../6x09/fixedpt.asm

all: $(TGTS)

mandelbr.dsk: coco12-mandel.bas coco3-mandel.bas MANDEL.BIN MANDELH.BIN MANDEL3.BIN MANDEL3H.BIN
	decb dskini $@
	decb copy -tb0 coco12-mandel.bas $@,MANDEL.BAS
	decb copy -tb0 coco3-mandel.bas $@,MANDELB3.BAS
	decb copy -b2 MANDEL.BIN $@,MANDEL.BIN
	decb copy -b2 MANDELH.BIN $@,MANDELH.BIN
	decb copy -b2 MANDEL3.BIN $@,MANDEL3.BIN
	decb copy -b2 MANDEL3H.BIN $@,MANDEL3H.BIN

mandelbr.vdk: MANDELD.BIN MANDELDH.BIN
	rm -f $@
	dragondos create $@
	dragondos write $@ MANDEL.BIN MANDELD.BIN
	dragondos write $@ MANDELH.BIN MANDELDH.BIN
	dragondos write $@ MANDEL.BAS dragon-mandel_tok.bas -basic

MANDEL.BIN: coco12-mandel.asm $(SPT)
	lwasm -o $@ $<

MANDELH.BIN: coco12-mandel.asm $(SPT)
	lwasm -Dh6309 -o $@ $<

MANDEL3.BIN: coco3-mandel.asm $(SPT)
	lwasm -o $@ $<

MANDEL3H.BIN: coco3-mandel.asm $(SPT)
	lwasm -Dh6309 -o $@ $<

MANDELD.BIN: MANDEL.BIN
	decb_ddos <$< >$@

MANDELDH.BIN: MANDELH.BIN
	decb_ddos <$< >$@

.PHONY: all clean distclean

clean:
	rm -f *~ *# *.BIN

distclean: clean
	rm -f $(TGTS)
