mkdir build &&
pushd    build &&

meson --prefix=/usr -Dbash_completion=false .. &&
ninja
#ninja test
ninja install

popd   #build           &&
tar -xf $BLFS_SRC_DIR/dconf-editor-3.38.2.tar.xz &&
pushd dconf-editor-3.38.2                &&

mkdir build &&
pushd    build &&

meson --prefix=/usr .. &&
ninja

ninja install

popd  #build
popd  #dconf-editor-3.38.2