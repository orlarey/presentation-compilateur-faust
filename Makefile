
all: slides.pdf slides-en.pdf

slides.pdf : slides.md examples/* graphs/* images/*
	make -C examples
	make -C graphs
	pandoc --to=beamer --standalone --output=slides.pdf slides.md

slides-en.pdf : slides-en.md examples/* graphs/* images/*
	make -C examples
	make -C graphs
	pandoc --to=beamer --standalone --output=slides-en.pdf slides-en.md

clean:
	rm -f slides.pdf slides-en.pdf
	make -C examples clean
	make -C graphs clean
