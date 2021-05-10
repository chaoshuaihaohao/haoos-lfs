sed -i 's:$(LIBDIR)/$(PKGCONFIG_DIR):/usr/lib/pkgconfig:' Makefile &&
make

#sed -i '/find/s:/usr/bin/::' tests/Makefile &&
#make -k test 

make NO_ARLIB=1 install