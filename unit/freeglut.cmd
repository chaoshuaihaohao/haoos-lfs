patch -Np1 -i $BLFS_SRC_DIR/freeglut-3.2.1-gcc10_fix-1.patch

mkdir build 
pushd    build 

cmake -DCMAKE_INSTALL_PREFIX=/usr       \
      -DCMAKE_BUILD_TYPE=Release        \
      -DFREEGLUT_BUILD_DEMOS=OFF        \
      -DFREEGLUT_BUILD_STATIC_LIBS=OFF  \
      -Wno-dev .. 

make

make install

popd