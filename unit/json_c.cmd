mkdir build &&
cd    build &&

cmake -DCMAKE_INSTALL_PREFIX=/usr \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_STATIC_LIBS=OFF    \
      .. &&
make

#make check

make install