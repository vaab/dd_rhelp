bin_SCRIPTS = dd_rhelp
CLEANFILES = $(bin_SCRIPTS) $(bin_PROGRAMS)
EXTRA_DIST = src/dd_rhelp-sh src/include/copyright-sh.in src/include/GPL-sh src/include/vars-sh.in src/include/end-sh.in src/include/begin-sh.in src/include/libcolor.sh src/include/libcommon.sh

dd_rhelp: $(srcdir)/src/dd_rhelp-sh $(top_builddir)/src/include/begin-sh $(top_builddir)/src/include/copyright-sh $(srcdir)/src/include/GPL-sh $(top_builddir)/src/include/vars-sh $(top_builddir)/src/include/end-sh $(srcdir)/TODO $(srcdir)/src/include/libcolor.sh $(srcdir)/src/include/libcommon.sh
	rm -f dd_rhelp
	echo "#!$(BASH)" > dd_rhelp
	cat $(top_builddir)/src/include/begin-sh >> dd_rhelp
	cat $(top_builddir)/src/include/copyright-sh >> dd_rhelp
	cat $(srcdir)/src/include/GPL-sh >> dd_rhelp
	echo "# TODO : " >> dd_rhelp
	cat $(srcdir)/TODO | sed 's/^/# /g' >> dd_rhelp
	cat $(top_builddir)/src/include/vars-sh >> dd_rhelp
	echo "# Including 'libcolor.sh'" >> dd_rhelp
	cat $(srcdir)/src/include/libcolor.sh >> dd_rhelp
	echo "# Including 'libcommon.sh'" >> dd_rhelp
	cat $(srcdir)/src/include/libcommon.sh >> dd_rhelp
	cat $(srcdir)/src/dd_rhelp-sh >> dd_rhelp
	cat $(top_builddir)/src/include/end-sh >> dd_rhelp
	chmod ugo+x dd_rhelp
