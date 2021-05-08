mkdir build &&
cd    build &&

meson --prefix /usr --default-library shared .. &&
ninja
#ninja test
ninja install