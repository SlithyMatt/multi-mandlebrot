TGTS=mandelbr.dsk mandelbr.vdk
SPT=../6x09/mandelbrot.asm ../6x09/fixedpt.asm
SPT24=$(SPT) ../6x09/mandelbrot24.asm ../6x09/fixedpt24.asm
COCO=MAND1L8.BIN MAND1L3.BIN MAND1H8.BIN MAND1H3.BIN coco12-mandel.bas 
COCO3=MAND3L8.BIN MAND3L3.BIN MAND3H8.BIN MAND3H3.BIN coco3-mandel.bas 
DRAGON=MANDDL8.BIN MANDDL3.BIN MANDDH8.BIN MANDDH3.BIN dragon-mandel_tok.bas 
VGA=MANDVL8.BIN MANDVL3.BIN MANDVH8.BIN MANDVH3.BIN
#MSX=MANDWL8.BIN MANDWL3.BIN MANDWH8.BIN MANDWH3.BIN
DVGA=MANDDVL8.BIN MANDDVL3.BIN MANDDVH8.BIN MANDDVH3.BIN
#DMSX=MANDWL8.BIN MANDWL3.BIN MANDWH8.BIN MANDWH3.BIN

all: $(TGTS)

mandelbr.dsk: $(COCO) $(COCO3) $(VGA)
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

mandelbr.vdk: $(DRAGON) $(DVGA)
	rm -f $@
	dragondos create $@
	dragondos write $@ MANDDL8.BIN MANDDL8.BIN
	dragondos write $@ MANDDL3.BIN MANDDL3.BIN
	dragondos write $@ MANDDH8.BIN MANDDH8.BIN
	dragondos write $@ MANDDH3.BIN MANDDH3.BIN
	dragondos write $@ MANDDVL8.BIN MANDDVL8.BIN
	dragondos write $@ MANDDVL3.BIN MANDDVL3.BIN
	dragondos write $@ MANDDVH8.BIN MANDDVH8.BIN
	dragondos write $@ MANDDVH3.BIN MANDDVH3.BIN
	dragondos write $@ MANDELD.BAS dragon-mandel_tok.bas -basic

# m6847
MAND1L8.BIN: coco-mandel.asm m6847.asm $(SPT)
	lwasm -o $@ $<

MAND1L3.BIN: coco-mandel.asm m6847.asm $(SPT)
	lwasm -Dh6309 -o $@ $<

MAND1H8.BIN: coco-mandel.asm m6847-hires.asm $(SPT24)
	lwasm -Dhires -o $@ $<

MAND1H3.BIN: coco-mandel.asm m6847-hires.asm $(SPT24)
	lwasm -Dhires -Dh6309 -o $@ $<

# gime
MAND3L8.BIN: coco-mandel.asm gime.asm $(SPT)
	lwasm -Dcoco3 -o $@ $<

MAND3L3.BIN: coco-mandel.asm gime.asm $(SPT)
	lwasm -Dcoco3 -Dh6309 -o $@ $<

MAND3H8.BIN: coco-mandel.asm m6847-hires.asm $(SPT24)
	lwasm -Dcoco3 -Dhires -o $@ $<

MAND3H3.BIN: coco-mandel.asm m6847-hires.asm $(SPT24)
	lwasm -Dcoco3 -Dhires -Dh6309 -o $@ $<

# cocovga
MANDVL8.BIN: coco-mandel.asm cocovga.asm cocovga-page.asm $(SPT)
	lwasm -Dvga -o $@ $<

MANDVL3.BIN: coco-mandel.asm cocovga.asm cocovga-page.asm $(SPT)
	lwasm -Dvga -D6309 -o $@ $<

MANDVH8.BIN: coco-mandel.asm cocovga.asm cocovga-page.asm $(SPT24)
	lwasm -Dvga -Dhires -o $@ $<

MANDVH3.BIN: coco-mandel.asm cocovga.asm cocovga-page.asm $(SPT24)
	lwasm -Dvga -Dhires -D6309 -o $@ $<

# SuperSprite FM+/WordPak 2+
MANDML8.BIN: coco-mandel.asm cocov9958.asm $(SPT)
	lwasm -Dv9958 -o $@ $<

MANDML3.BIN: coco-mandel.asm cocov9958.asm $(SPT)
	lwasm -Dv9958 -D6309 -o $@ $<

MANDMH8.BIN: coco-mandel.asm cocov9958-hires.asm $(SPT24)
	lwasm -Dv9958 -Dhires -o $@ $<

MANDMH3.BIN: coco-mandel.asm cocov9958-hires.asm $(SPT24)
	lwasm -Dv9958 -Dhires -D6309 -o $@ $<

MANDDL8.BIN: MAND1L8.BIN
	decb_ddos <$< >$@

MANDDL3.BIN: MAND1L3.BIN
	decb_ddos <$< >$@

MANDDH8.BIN: MAND1H8.BIN
	decb_ddos <$< >$@

MANDDH3.BIN: MAND1H3.BIN
	decb_ddos <$< >$@

MANDDVL8.BIN: MANDVL8.BIN
	decb_ddos <$< >$@

MANDDVL3.BIN: MANDVL3.BIN
	decb_ddos <$< >$@

MANDDVH8.BIN: MANDVH8.BIN
	decb_ddos <$< >$@

MANDDVH3.BIN: MANDVH3.BIN
	decb_ddos <$< >$@

MANDDML8.BIN: MANDML8.BIN
	decb_ddos <$< >$@

MANDDML3.BIN: MANDML3.BIN
	decb_ddos <$< >$@

MANDDMH8.BIN: MANDMH8.BIN
	decb_ddos <$< >$@

MANDDMH3.BIN: MANDMH3.BIN
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
