mkdir build &&
pushd    build &&

meson --prefix=/usr .. &&
ninja
#ninja test
ninja install
popd