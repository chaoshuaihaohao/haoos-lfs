sed -i 's/test_exe,/test_exe, depends: [libintrospection_gir],/' tests/libpeas/meson.build

mkdir build &&
cd    build &&

meson --prefix=/usr .. &&
ninja

#ninja test

ninja install