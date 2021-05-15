patch -Np1 -i $BLFS_SRC_DIR/libgrss-0.7.0-bugfixes-1.patch &&
autoreconf -fv &&
./configure --prefix=/usr --disable-static &&
make

#make check

make install