TGTS=mandelbr.vdk
BASIC=dragon-mandel_tok.bas

all: $(TGTS)

mandelbr.vdk: $(DRAGON) $(BASIC)
	rm -f $@
	dragondos create $@
	dragondos write $@ MANDELD.BAS dragon-mandel_tok.bas -basic
	./ddosadd.sh $@ $(DRAGON)

.PHONY: all

clean:
	rm -f $(DRAGON) *~ *#

distclean: clean
	rm -f $(TGTS)
