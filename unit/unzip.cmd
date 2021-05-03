make -f unix/Makefile generic
make prefix=/usr MANDIR=/usr/share/man/man1 \
 -f unix/Makefile install