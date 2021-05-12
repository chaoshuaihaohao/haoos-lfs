mkdir build &&
cd    build &&

meson --prefix=$XORG_PREFIX .. &&
ninja

#ninja test

ninja install