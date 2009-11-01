CC=			gcc
CFLAGS=		-g -Wall #-O2 #-m64 #-arch ppc
DFLAGS=		-D_FILE_OFFSET_BITS=64 -D_USE_KNETFILE
LOBJS=		bgzf.o kstring.o knetfile.o index.o
AOBJS=		main.o
PROG=		tabix bgzip
INCLUDES=
SUBDIRS=	.
LIBPATH=
LIBCURSES=	

.SUFFIXES:.c .o

.c.o:
		$(CC) -c $(CFLAGS) $(DFLAGS) $(INCLUDES) $< -o $@

all-recur lib-recur clean-recur cleanlocal-recur install-recur:
		@target=`echo $@ | sed s/-recur//`; \
		wdir=`pwd`; \
		list='$(SUBDIRS)'; for subdir in $$list; do \
			cd $$subdir; \
			$(MAKE) CC="$(CC)" DFLAGS="$(DFLAGS)" CFLAGS="$(CFLAGS)" \
				INCLUDES="$(INCLUDES)" LIBPATH="$(LIBPATH)" $$target || exit 1; \
			cd $$wdir; \
		done;

all:$(PROG)

lib:libtabix.a

libtabix.a:$(LOBJS)
		$(AR) -cru $@ $(LOBJS)

tabix:lib $(AOBJS)
		$(CC) $(CFLAGS) -o $@ $(AOBJS) -lm $(LIBPATH) -lz -L. -ltabix

bgzip:bgzip.o bgzf.o knetfile.o
		$(CC) $(CFLAGS) -o $@ bgzip.o bgzf.o knetfile.o -lz

bgzf.o:bgzf.h knetfile.h
knetfile.o:knetfile.h
index.o:tabix.h khash.h ksort.h kstring.h
main.o:tabix.h

cleanlocal:
		rm -fr gmon.out *.o a.out *.dSYM $(PROG) *~ *.a

clean:cleanlocal-recur
