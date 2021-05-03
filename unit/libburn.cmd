rm -rf libburn-1.5.4
tar xf $BLFS_SRC_DIR/libburn-1.5.4.tar.gz
pushd libburn-1.5.4
./configure --prefix=/usr --disable-static &&
make
#doxygen doc/doxygen.conf
make install
install -v -dm755 /usr/share/doc/libburn-1.5.4 &&
#install -v -m644 doc/html/* /usr/share/doc/libburn-1.5.4
popd
rm -rf libburn-1.5.4
