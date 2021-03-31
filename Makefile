slides.pdf : slides.md slides1.md examples/*.dsp
	make -C examples
	pandoc --to=beamer --standalone --output=slides.pdf slides.md
	pandoc --to=beamer --standalone --output=slides1.pdf slides1.md

clean:
	rm -f slides.pdf slides1.pdf
	make -C examples clean
