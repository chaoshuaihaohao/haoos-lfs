mkdir build &&
pushd    build &&

meson --prefix=$XORG_PREFIX \
      -Dudev-dir=/lib/udev  \
      -Ddebug-gui=false     \
      -Dtests=false         \
      -Ddocumentation=false \
      -Dlibwacom=false      \
      ..                    &&
ninja

ninja install

install -v -dm755      /usr/share/doc/libinput-1.16.4/{html,api} &&
cp -rv Documentation/* /usr/share/doc/libinput-1.16.4/html &&
cp -rv api/*           /usr/share/doc/libinput-1.16.4/api

popd