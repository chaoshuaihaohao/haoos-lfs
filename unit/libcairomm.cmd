mkdir bld &&
cd    bld &&

meson --prefix=/usr       \
      -Dbuild-tests=true  \
      -Dboost-shared=true \
      ..                  &&
ninja

#ninja test

ninja install -j1
