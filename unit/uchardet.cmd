mkdir build &&
cd    build &&
     
cmake -DCMAKE_INSTALL_PREFIX=/usr \
      -DBUILD_STATIC=OFF          \
      -Wno-dev ..                 &&
make

#make check

make install