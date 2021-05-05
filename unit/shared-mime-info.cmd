mkdir build &&
pushd    build &&

meson --prefix=/usr -Dupdate-mimedb=true .. &&
ninja
ninja install
popd