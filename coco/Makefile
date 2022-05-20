export COCO
export DRAGON
TGTS=mandelbr.dsk mandelbr.vdk
SPT=../6x09/mandelbrot.asm ../6x09/fixedpt.asm
SPT24=$(SPT) ../6x09/mandelbrot24.asm ../6x09/fixedpt24.asm
COCO1=MAND1L8.BIN MAND1L3.BIN MAND1H8.BIN MAND1H3.BIN
COCO3=MAND3L8.BIN MAND3L3.BIN MAND3H8.BIN MAND3H3.BIN
VGA=MANDVL8.BIN MANDVL3.BIN MANDVH8.BIN MANDVH3.BIN
MSX=MANDML8.BIN MANDML3.BIN MANDMH8.BIN MANDMH3.BIN
COCO=$(COCO1) $(COCO3) $(VGA) $(MSX)
DRAGON=$(COCO1) $(VGA) $(MSX)

all: coco dragon

coco: $(addprefix coco/,$(COCO))
	make -C coco

dragon: $(addprefix dragon/,$(DRAGON))
	make -C dragon

coco/mandelbr.dsk: coco

dragon/mandelbr.vdk: dragon

# m6847
coco/MAND1L8.BIN: coco-mandel.asm m6847.asm $(SPT)
	lwasm -o $@ $<

coco/MAND1L3.BIN: coco-mandel.asm m6847.asm $(SPT)
	lwasm -Dh6309 -o $@ $<

coco/MAND1H8.BIN: coco-mandel.asm m6847-hires.asm $(SPT24)
	lwasm -Dhires -o $@ $<

coco/MAND1H3.BIN: coco-mandel.asm m6847-hires.asm $(SPT24)
	lwasm -Dhires -Dh6309 -o $@ $<

# gime
coco/MAND3L8.BIN: coco-mandel.asm gime.asm $(SPT)
	lwasm -Dcoco3 -o $@ $<

coco/MAND3L3.BIN: coco-mandel.asm gime.asm $(SPT)
	lwasm -Dcoco3 -Dh6309 -o $@ $<

coco/MAND3H8.BIN: coco-mandel.asm m6847-hires.asm $(SPT24)
	lwasm -Dcoco3 -Dhires -o $@ $<

coco/MAND3H3.BIN: coco-mandel.asm m6847-hires.asm $(SPT24)
	lwasm -Dcoco3 -Dhires -Dh6309 -o $@ $<

# cocovga
coco/MANDVL8.BIN: coco-mandel.asm cocovga.asm cocovga-page.asm $(SPT)
	lwasm -Dvga -o $@ $<

coco/MANDVL3.BIN: coco-mandel.asm cocovga.asm cocovga-page.asm $(SPT)
	lwasm -Dvga -D6309 -o $@ $<

coco/MANDVH8.BIN: coco-mandel.asm cocovga.asm cocovga-page.asm $(SPT24)
	lwasm -Dvga -Dhires -o $@ $<

coco/MANDVH3.BIN: coco-mandel.asm cocovga.asm cocovga-page.asm $(SPT24)
	lwasm -Dvga -Dhires -D6309 -o $@ $<

# SuperSprite FM+/WordPak 2+
coco/MANDML8.BIN: coco-mandel.asm v9958.asm $(SPT)
	lwasm -Dv9958 -Dmpi -Dc2mhz -o $@ $<

coco/MANDML3.BIN: coco-mandel.asm v9958.asm $(SPT)
	lwasm -Dv9958 -Dmpi -Dc2mhz -D6309 -o $@ $<

coco/MANDMH8.BIN: coco-mandel.asm v9958.asm $(SPT24)
	lwasm -Dv9958 -Dmpi -Dc2mhz -Dhires -o $@ $<

coco/MANDMH3.BIN: coco-mandel.asm v9958.asm $(SPT24)
	lwasm -Dv9958 -Dmpi -Dc2mhz -Dhires -D6309 -o $@ $<

dragon/%: coco/%
	decb_ddos <$< >$@

.PHONY: all clean distclean test coco dragon

clean:
	make -C coco clean
	make -C dragon clean
	rm -f *~ *#

distclean: clean
	make -C coco distclean
	make -C dragon distclean
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

install: coco/mandelbr.dsk dragon/mandelbr.vdk
	cp $^ disks
