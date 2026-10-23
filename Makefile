# Build the CV PDFs and the website.
#   make cv     -> assets/cv/cv-academic.pdf, assets/cv/cv-industry.pdf
#   make site   -> CV PDFs, then the full website in _site/
#   make clean  -> remove generated CV files
# Both read data/cv.yml and data/publications.bib.

VARIANTS := academic industry
PDFS := $(VARIANTS:%=assets/cv/cv-%.pdf)

.PHONY: cv site clean

cv: $(PDFS)

assets/cv/cv-%.pdf: data/cv.yml data/publications.bib _cv/cv.qmd _cv/cv.lua _cv/cv-style.typ _cv/_quarto.yml _cv/_quarto-%.yml
	cd _cv && quarto render cv.qmd --profile $*
	mkdir -p assets/cv
	mv _cv/cv-$*.pdf $@

site: cv
	quarto render

clean:
	rm -rf assets/cv _cv/cv.typ _cv/cv_files _cv/*.pdf
