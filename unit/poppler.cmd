mkdir build                         &&
cd    build                         &&

cmake  -DCMAKE_BUILD_TYPE=Release   \
       -DCMAKE_INSTALL_PREFIX=/usr  \
       -DTESTDATADIR=$PWD/testfiles \
       -DENABLE_UNSTABLE_API_ABI_HEADERS=ON \
       ..                           &&
make

make install


install -v -m755 -d           /usr/share/doc/poppler-21.02.0 &&
cp -vr ../glib/reference/html /usr/share/doc/poppler-21.02.0

tar -xf $BLFS_SRC_DIR/poppler-data-0.4.10.tar.gz &&
cd poppler-data-0.4.10

make prefix=/usr install