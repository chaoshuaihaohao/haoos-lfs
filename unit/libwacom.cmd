mkdir build &&
cd    build &&

meson --prefix=/usr -Dudev-dir=/lib/udev -Dtests=disabled .. &&
ninja
#ninja test
ninja install