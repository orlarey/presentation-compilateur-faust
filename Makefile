
slides.pdf : slides.md examples/* graphs/* images/*
	make -C examples
	make -C graphs
	pandoc --to=beamer --standalone --output=slides.pdf slides.md

clean:
	rm -f slides.pdf 
	make -C examples clean
	make -C graphs clean
