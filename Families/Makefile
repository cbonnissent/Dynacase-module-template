# ============================================
# $Id: Makefile,v 1.1 2010-01-13 10:47:16 eric Exp $
#
# ============================================

SUBDIR= Views Externals

include $(utildir)/PubRule

pages_fdl = $(patsubst %.php,$(pubdir)/$(applib)/%.php,$(wildcard Method*.php))
pages_fdl += $(patsubst %.php,$(pubdir)/$(applib)/%.php,$(wildcard Class*.php))

$(pubdir)/$(applib):
	mkdir $@

$(pubdir)/$(applib)/%.php: %.php $(pubdir)/$(applib)
	cd $(pubdir)/$(applib); \
	ln -sf ../$(appname)/$< .

publish: $(pubdir)/$(applib) $(pages_fdl) 