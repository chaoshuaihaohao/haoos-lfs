mkdir build &&
pushd    build &&

meson --prefix=/usr -Ddocs=false .. &&
ninja
#ninja test
ninja install

popd