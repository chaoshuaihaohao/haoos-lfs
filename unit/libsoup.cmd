patch -Np1 -i $BLFS_SRC_DIR/libsoup-2.72.0-testsuite_fix-1.patch

mkdir build &&
pushd    build &&

meson --prefix=/usr -Dvapi=enabled -Dgssapi=disabled .. &&
ninja

ninja test

ninja install

popd