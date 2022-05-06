TGTS=mandelbr.dsk mandelbr.vdk
SPT=../6x09/mandelbrot.asm ../6x09/fixedpt.asm
SPT24=$(SPT) ../6x09/mandelbrot24.asm ../6x09/fixedpt24.asm
COCO=MAND1L8.BIN MAND1L3.BIN MAND1H8.BIN MAND1H3.BIN coco12-mandel.bas 
COCO3=MAND3L8.BIN MAND3L3.BIN MAND3H8.BIN MAND3H3.BIN coco3-mandel.bas 
DRAGON=MANDDL8.BIN MANDDL3.BIN MANDDH8.BIN MANDDH3.BIN dragon-mandel_tok.bas 

all: $(TGTS)

mandelbr.dsk: $(COCO) $(COCO3)
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

mandelbr.vdk: $(DRAGON)
	rm -f $@
	dragondos create $@
	dragondos write $@ MANDDL8.BIN MANDDL8.BIN
	dragondos write $@ MANDDL3.BIN MANDDL3.BIN
	dragondos write $@ MANDDH8.BIN MANDDH8.BIN
	dragondos write $@ MANDDH3.BIN MANDDH3.BIN
	dragondos write $@ MANDELD.BAS dragon-mandel_tok.bas -basic

MAND1L8.BIN: coco-mandel.asm m6847.asm $(SPT)
	lwasm -o $@ $<

MAND1L3.BIN: coco-mandel.asm m6847.asm $(SPT)
	lwasm -Dh6309 -o $@ $<

MAND1H8.BIN: coco-mandel.asm m6847-hires.asm $(SPT24)
	lwasm -Dhires -o $@ $<

MAND1H3.BIN: coco-mandel.asm m6847-hires.asm $(SPT24)
	lwasm -Dhires -Dh6309 -o $@ $<

MAND3L8.BIN: coco-mandel.asm gime.asm $(SPT)
	lwasm -Dcoco3 -o $@ $<

MAND3L3.BIN: coco-mandel.asm gime.asm $(SPT)
	lwasm -Dcoco3 -Dh6309 -o $@ $<

MAND3H8.BIN: coco-mandel.asm m6847-hires.asm $(SPT24)
	lwasm -Dcoco3 -Dhires -o $@ $<

MAND3H3.BIN: coco-mandel.asm m6847-hires.asm $(SPT24)
	lwasm -Dcoco3 -Dhires -Dh6309 -o $@ $<

MANDDL8.BIN: MAND1L8.BIN
	decb_ddos <$< >$@

MANDDL3.BIN: MAND1L3.BIN
	decb_ddos <$< >$@

MANDDH8.BIN: MAND1H8.BIN
	decb_ddos <$< >$@

MANDDH3.BIN: MAND1H3.BIN
	decb_ddos <$< >$@

.PHONY: all clean distclean test

clean:
	rm -f *~ *# *.BIN

distclean: clean
	rm -f $(TGTS)

test: all
	- xroar -machine dragon32 dragon-mandel.bas
	- xroar -machine dragon32 MANDDL8.BIN
	- xroar -machine dragon32 -machine-cpu 6309 MANDDL3.BIN
	- xroar -machine dragon32 MANDDH8.BIN
	- xroar -machine dragon32 -machine-cpu 6309 MANDDH3.BIN
	- xroar -machine cocous coco12-mandel.bas
	- xroar -machine cocous MAND1L8.BIN
	- xroar -machine cocous -machine-cpu 6309 MAND1L3.BIN
	- xroar -machine cocous MAND1H8.BIN
	- xroar -machine cocous -machine-cpu 6309 MAND1H3.BIN
	- xroar -machine coco3 coco3-mandel.bas
	- xroar -machine coco3 MAND3L8.BIN
	- xroar -machine coco3 -machine-cpu 6309 MAND3L3.BIN
	- xroar -machine coco3 MAND3H8.BIN
	- xroar -machine coco3 -machine-cpu 6309 MAND3H3.BIN
