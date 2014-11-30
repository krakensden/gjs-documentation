outdir ?= .
prefix ?= /opt/gnome
datadir ?= $(prefix)/share
girdir = $(datadir)/gir-1.0

STATIC_NAMESPACES = \
	GLib-2.0		\
	Gio-2.0			\
	GObject-2.0		\

AVAILABLE_NAMESPACES = $(wildcard $(girdir)/*)
GENERATED_NAMESPACES = $(basename $(notdir $(AVAILABLE_NAMESPACES)))

NAMESPACES = $(STATIC_NAMESPACES) $(GENERATED_NAMESPACES)

GIRS = $(foreach g,$(NAMESPACES),$(girdir)/$(g).gir)
STATIC_MALLARDS = $(foreach g,$(STATIC_NAMESPACES),$(outdir)/static/$(g))
GENERATED_MALLARDS = $(foreach g,$(GENERATED_NAMESPACES),$(outdir)/generated/$(g))
MALLARDS = $(STATIC_MALLARDS) $(GENERATED_MALLARDS)
HTMLS = $(foreach g,$(NAMESPACES),html/$(g))

all: $(HTMLS)

$(outdir)/static/%: $(girdir)/%.gir
	g-ir-doc-tool --language=Gjs -o $@ $<
	touch $@
$(outdir)/generated/%: $(girdir)/%.gir
	g-ir-doc-tool --language=Gjs -o $@ $<
	touch $@

update-mallard: $(MALLARDS)

html/%: $(outdir)/static/%
	mkdir -p $@
	yelp-build html -o $@ $<
	touch $@
html/%: $(outdir)/generated/%
	mkdir -p $@
	yelp-build html -o $@ $<
	touch $@

upload: all
	rsync -av --delete html/ master.gnome.org:public_html/docs/

clean:
	-rm -fr $(HTMLS)
maintainerclean:
	-rm -fr $(GENERATED_MALLARDS)
