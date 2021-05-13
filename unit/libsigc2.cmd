mkdir bld &&
cd    bld &&

meson --prefix=/usr .. &&
ninja

#ninja test

ninja install