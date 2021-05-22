mkdir build &&
cd    build &&

meson --prefix=/usr .. &&
ninja

#ninja test

ninja install