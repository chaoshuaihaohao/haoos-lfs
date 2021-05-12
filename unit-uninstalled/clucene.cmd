patch -Np1 -i $BLFS_SRC_DIR/clucene-2.3.3.4-contribs_lib-1.patch &&

mkdir build &&
cd    build &&

cmake -DCMAKE_INSTALL_PREFIX=/usr \
      -DBUILD_CONTRIBS_LIB=ON .. &&
make

make install