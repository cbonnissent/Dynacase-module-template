include $(utildir)/PubRule

pages_fdl = $(patsubst %.php,$(pubdir)/$(applib)/%.php,$(wildcard *.php))

$(pubdir)/EXTERNALS :
	mkdir -p $@

$(pubdir)/$(applib)/%.php: %.php $(pubdir)/EXTERNALS
	cd $(pubdir)/$(style)/EXTERNALS; \
	ln -sf ../$(appname)/$< .

publish: $(pubdir)/EXTERNALS $(pages_fdl)