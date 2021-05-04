sed '1i CFLAGS += -fcommon' Makefile > Makefile-lfs-tmp
mv Makefile-lfs-tmp Makefile
make
make install PREFIX=/usr
ln -sfv  /usr/bin/genisoimage  /usr/bin/mkisofs