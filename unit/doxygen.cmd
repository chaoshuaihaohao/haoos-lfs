mkdir -v build &&
pushd       build &&

cmake -G "Unix Makefiles"         \
      -DCMAKE_BUILD_TYPE=Release  \
      -DCMAKE_INSTALL_PREFIX=/usr \
      -Wno-dev .. &&

make
#make test

cmake -DDOC_INSTALL_DIR=share/doc/doxygen-1.9.1 -Dbuild_doc=ON .. &&

make docs

make install &&
install -vm644 ../doc/*.1 /usr/share/man/man1

popd