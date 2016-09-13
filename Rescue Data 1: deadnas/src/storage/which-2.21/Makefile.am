AUTOMAKE_OPTIONS = no-texinfo.tex
ACLOCAL_AMFLAGS=@ACLOCAL_CWFLAGS@

SUBDIRS = tilde .

BUILT_SOURCES =
EXTRA_DIST = COPYING $(man_MANS) $(BUILT_SOURCES) README.alias README EXAMPLES which.1
DISTCLEANFILES=config.cache config.log config.h

bin_PROGRAMS = which

which_SOURCES = \
	getopt.c \
	getopt1.c \
	bash.c \
	which.c \
	bash.h \
	sys.h \
	getopt.h \
	posixstat.h

LDADD = $(top_builddir)/tilde/libtilde.a
info_TEXINFOS = which.texi
man_MANS = which.1

# --------------- Maintainer's Section

dist-local: which README EXAMPLES which.1

distclean-local:
	rm -rf .deps autom4te-*.cache which-*.tar.gz

MAINTAINERCLEANFILES=aclocal.m4 Makefile.in config.h.in stamp-h.in configure \
        ChangeLog EXAMPLES which-2.spec index.html cvslog-*.html README \
	texinfo2man which.1 install-sh missing mkinstalldirs \
	config.cache config.log depcomp compile config.status which.lsm

@MAINTAINER_MODE_TRUE@include maintMakefile
