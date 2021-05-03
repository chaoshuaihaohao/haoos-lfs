rm -rf gpgme-1.15.1
tar xf $BLFS_SRC_DIR/gpgme-1.15.1.tar.bz2
pushd gpgme-1.15.1
./configure --prefix=/usr --disable-gpg-test &&
make
make install
popd
rm -rf gpgme-1.15.1
