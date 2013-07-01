include $(utildir)/PubRule

pages_fdl = $(patsubst %.php,$(pubdir)/$(applib)/%.php,$(wildcard *.php))

$(pubdir)/API:
	mkdir -p $@

$(pubdir)/$(applib)/%.php: %.php $(pubdir)/API
	cd $(pubdir)/API; \
	ln -sf ../$(appname)/$< .

publish: $(pubdir)/API $(pages_fdl)