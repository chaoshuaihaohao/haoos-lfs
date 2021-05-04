pushd squashfs-tools
sed '1i CFLAGS += -fcommon' Makefile > Makefile-lfs-tmp
mv Makefile-lfs-tmp Makefile
make
make install INSTALL_DIR=/usr/bin
popd