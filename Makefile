# Build the CV PDF and the website.
#   make cv     -> assets/cv/Shubhankar_Londhe_CV.pdf
#   make site   -> CV PDF, then the full website in _site/
#   make clean  -> remove generated CV files
# Both read data/cv.yml and data/publications.bib.

CV := assets/cv/Shubhankar_Londhe_CV.pdf

.PHONY: cv site clean

cv: $(CV)

$(CV): data/cv.yml data/publications.bib assets/img/prof_pic.jpg _cv/cv.qmd _cv/cv.lua _cv/cv-style.typ _cv/_quarto.yml
	cd _cv && quarto render cv.qmd
	mkdir -p assets/cv
	mv _cv/Shubhankar_Londhe_CV.pdf $@

site: cv
	quarto render

clean:
	rm -rf assets/cv _cv/cv.typ _cv/cv_files _cv/*.pdf _cv/cv-photo.*
