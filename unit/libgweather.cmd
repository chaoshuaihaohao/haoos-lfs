mkdir build &&
pushd    build &&

meson --prefix=/usr .. &&
ninja
#LANG=C ninja test
ninja install
popd