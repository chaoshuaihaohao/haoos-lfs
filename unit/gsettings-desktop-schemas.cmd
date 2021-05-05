sed -i -r 's:"(/system):"/org/gnome\1:g' schemas/*.in &&

mkdir build &&
pushd    build &&

meson --prefix=/usr .. &&
ninja
ninja install
popd