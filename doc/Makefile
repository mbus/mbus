FIGS =

SVGS = $(wildcard img/*.svg)
EPSS = $(patsubst %.svg,%.eps,$(SVGS))

GVS = $(wildcard img/*.gv)
EPSS += $(patsubst %.gv,%.eps,$(GVS))

PDFS = $(patsubst %.eps,%.pdf,$(EPSS))

FIGS += $(EPSS) $(PDFS)

TARGETS = implementation.pdf $(FIGS)

all:	$(TARGETS)

%.pdf: %.eps
	epstopdf $<

%.eps: %.ps
	ps2eps -f $<

%.ps: %.gv
	dot -Tps $< -o $@

%.ps: %.svg
	rsvg-convert -f ps -o $@ $<

implementation.pdf:	$(wildcard *.tex) $(FIGS)
	pdflatex implementation.tex
	pdflatex implementation.tex

clean:
	rm -f *.aux *.log *.out *.toc
	rm -f $(TARGETS)
