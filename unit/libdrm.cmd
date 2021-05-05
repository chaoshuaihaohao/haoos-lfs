mkdir build &&
pushd    build &&
meson --prefix=$XORG_PREFIX -Dudev=true &&
ninja
ninja install