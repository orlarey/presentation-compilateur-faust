
all: slides.pdf slides1.pdf

slides.pdf : slides.md examples/*.dsp
	make -C examples
	pandoc --to=beamer --standalone --output=slides.pdf slides.md

slides1.pdf : slides1.md examples/*.dsp
	pandoc --to=beamer --standalone --output=slides1.pdf slides1.md

clean:
	rm -f slides.pdf slides1.pdf
	make -C examples clean
