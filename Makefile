NBS := $(wildcard [0-9]*.ipynb)
ODP := $(wildcard *.odp)

all: $(ODP:%.odp=%.pdf) $(NBS:%.ipynb=%-slides.pdf) 

%.tex: %.ipynb
	nb2tex -n $^

%.pdf: %.odp
	# unoconv -o $@ $<
	true

%-slides.pdf: %.ipynb
	nb2tex -b $^
	pdflatex -file-line-error -interaction=batchmode $(^:%.ipynb=%-slides.tex) || true
	egrep ':[0-9]+:' $(^:%.ipynb=%-slides.log) | uniq

simso.pdf: simso.tex $(NBS:%.ipynb=%.tex)
	pdflatex -file-line-error -interaction=batchmode simso.tex || true
	pdflatex -file-line-error -interaction=batchmode simso.tex || true
	egrep ':[0-9]+:' simso.log | uniq

clean:
	rm -f $(NBS:%.ipynb=%.tex)
	rm -f $(NBS:%.ipynb=%-slides.tex)
	rm -f $(NBS:%.ipynb=%-slides.pdf)
	rm -f *.log *.nav *.snm *.toc *.vrb *.aux *.out

public: all
	mkindex > index.html
	rsync -v index.html simso.pdf $(NBS) $(NBS:%.ipynb=%-slides.pdf) iupr1.cs.uni-kl.de:public_html/simso

