./configure --prefix=/usr --disable-static &&
make

#make check

make install

tar -xf $BLFS_SRC_DIR/libcdio-paranoia-10.2+2.0.1.tar.bz2 &&
cd libcdio-paranoia-10.2+2.0.1 &&

./configure --prefix=/usr --disable-static &&
make

#make check

make install