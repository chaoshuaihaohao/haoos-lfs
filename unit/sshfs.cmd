mkdir build &&
pushd    build &&    
meson --prefix=/usr .. &&
ninja
ninja install
popd