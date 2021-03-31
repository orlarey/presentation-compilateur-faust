DSP := $(shell find . -name "*.dsp")
SVG	:= $(DSP:%.dsp=%.svg)
PDF	:= $(DSP:%.dsp=%.pdf)



all : $(PDF)

%.pdf : %.dsp-sig.dot
	dot -Tpdf -o "$@" "$<"

%.dsp-sig.dot : %.dsp
	faust -sg "$(<)" > /dev/null

clean :
	rm -f *.svg *.pdf