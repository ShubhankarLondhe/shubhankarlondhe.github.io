# Build the CV PDF and the website.
#   make cv     -> assets/cv/Shubhankar_Londhe_CV.pdf
#   make site   -> CV PDF, then the full website in _site/
#   make cv-private -> private/Shubhankar_Londhe_CV_private.pdf (not published)
#   make clean  -> remove generated CV files
# Both read data/cv.yml and data/publications.bib.

CV := assets/cv/Shubhankar_Londhe_CV.pdf

PRIVATE_CV := private/Shubhankar_Londhe_CV_private.pdf

.PHONY: cv cv-private site clean

cv: $(CV)

$(CV): data/cv.yml data/publications.bib _cv/cv.qmd _cv/cv.lua _cv/cv-style.typ _cv/_quarto.yml
	cd _cv && quarto render cv.qmd
	mkdir -p assets/cv
	mv _cv/Shubhankar_Londhe_CV.pdf $@

# Private CV with extra contact details from data/cv-private.yml (gitignored).
# Written to private/, which is gitignored and never part of the website.
cv-private: data/cv-private.yml
	cd _cv && CV_PRIVATE=1 quarto render cv.qmd
	mkdir -p private
	mv _cv/Shubhankar_Londhe_CV.pdf $(PRIVATE_CV)
	@echo "Private CV: $(PRIVATE_CV)"

data/cv-private.yml:
	@echo "Create data/cv-private.yml first (see data/cv-private.example.yml)"; exit 1

site: cv
	quarto render

clean:
	rm -rf assets/cv _cv/cv.typ _cv/cv_files _cv/*.pdf
