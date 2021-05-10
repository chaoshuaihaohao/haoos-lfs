./configure $XORG_CONFIG &&
make

make install

tar -xvf $BLFS_SRC_DIR/intel-vaapi-driver-2.4.1.tar.bz2 &&
cd intel-vaapi-driver-2.4.1

./configure $XORG_CONFIG &&
make

make install