mkdir bld &&
cd    bld &&

meson --prefix=/usr .. &&
ninja

ninja install