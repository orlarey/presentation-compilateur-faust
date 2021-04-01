DSP := $(shell find . -name "*.dsp")
SVG	:= $(DSP:%.dsp=%.svg)
PDF	:= $(DSP:%.dsp=%.pdf)



all : $(PDF)

%.pdf : %.dsp
	faust -sg "$(<)" > /dev/null
	dot -Tpdf -o "$@" "$(<)-sig.dot"
	rm "$(<)-sig.dot"

clean :
	rm -f *.svg *.pdf