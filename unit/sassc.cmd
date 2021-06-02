tar -xf $BLFS_SRC_DIR/libsass-3.6.4.tar.gz 
pushd libsass-3.6.4 

autoreconf -fi 

./configure --prefix=/usr --disable-static 
make

make install

popd 
autoreconf -fi 

./configure --prefix=/usr 
make

make install