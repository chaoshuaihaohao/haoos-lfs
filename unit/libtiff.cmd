mkdir -p libtiff-build &&
pushd       libtiff-build &&

cmake -DCMAKE_INSTALL_DOCDIR=/usr/share/doc/libtiff-4.2.0 \
      -DCMAKE_INSTALL_PREFIX=/usr -G Ninja .. &&
ninja
#ninja test
ninja install
popd