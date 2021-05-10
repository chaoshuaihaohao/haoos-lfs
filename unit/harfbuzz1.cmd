mkdir build &&
pushd    build &&

meson --prefix=/usr -Dgraphite=enabled -Dbenchmark=disabled &&
ninja
ninja install
popd