mkdir build &&
pushd build &&

meson --prefix=/usr .. &&
ninja
ninja install -j1
popd
