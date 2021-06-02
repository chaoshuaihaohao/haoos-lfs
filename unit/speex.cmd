./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/speex-1.2.0 
make
make install

pushd ..                          
tar -xf $BLFS_SRC_DIR/speexdsp-1.2.0.tar.gz 
pushd speexdsp-1.2.0             

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/speexdsp-1.2.0 
make

make install

popd

popd