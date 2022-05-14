TGTS=mandelbr.vdk
BASIC=dragon-mandel_tok.bas

all: $(TGTS)

mandelbr.vdk: $(DRAGON) $(BASIC)
	rm -f $@
	dragondos create $@
	dragondos write $@ MAND1L8.BIN MAND1L8.BIN
	dragondos write $@ MAND1L3.BIN MAND1L3.BIN
	dragondos write $@ MAND1H8.BIN MAND1H8.BIN
	dragondos write $@ MAND1H3.BIN MAND1H3.BIN
	dragondos write $@ MANDVL8.BIN MANDVL8.BIN
	dragondos write $@ MANDVL3.BIN MANDVL3.BIN
	dragondos write $@ MANDVH8.BIN MANDVH8.BIN
	dragondos write $@ MANDVH3.BIN MANDVH3.BIN
	dragondos write $@ MANDELD.BAS dragon-mandel_tok.bas -basic

.PHONY: all

clean:
	rm -f $(DRAGON) *~ *#

distclean: clean
	rm -f $(TGTS)
