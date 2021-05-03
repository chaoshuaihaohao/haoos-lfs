rm -rf libgpg-error-1.41
tar xf $BLFS_SRC_DIR/libgpg-error-1.41.tar.bz2
pushd libgpg-error-1.41
./configure --prefix=/usr &&
make
make install &&
install -v -m644 -D README /usr/share/doc/libgpg-error-1.41/README
popd
rm -rf libgpg-error-1.41
