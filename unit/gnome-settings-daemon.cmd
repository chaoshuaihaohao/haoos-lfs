rm -v -f /usr/lib/systemd/user/gsd-*

mkdir build &&
cd    build &&

meson --prefix=/usr .. &&
ninja

#ninja test

ninja install