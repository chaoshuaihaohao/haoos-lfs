mkdir build &&
cd    build &&

cmake -DCMAKE_INSTALL_PREFIX=/usr \
      -DBUILD_SHARED_LIBS=ON      \
      -DBUILD_TESTING=ON          \
      ..                          &&
make
make install