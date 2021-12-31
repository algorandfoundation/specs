pdf/%.pdf: %.md
	@mkdir -p $(@D)
	pandoc --toc --pdf-engine=xelatex --template template/default.latex -o $@ $<

html/%.html: %.md
	@mkdir -p $(@D)
	pandoc --toc --pdf-engine=xelatex -o $@ -s $< --mathjax

all: pdf html
.PHONY: all

pdf: $(patsubst %.md,pdf/%.pdf,$(wildcard *.md))
.PHONY: pdf

html: $(patsubst %.md,html/%.html,$(wildcard *.md))
.PHONY: html

clean:
	rm pdf/* html/*
.PHONY: clean
