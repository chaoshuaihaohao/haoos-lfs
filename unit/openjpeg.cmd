mkdir -v build &&
pushd       build &&

cmake -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/usr \
      -DBUILD_STATIC_LIBS=OFF .. &&
make

make install &&
popd

pushd doc &&
  for man in man/man?/* ; do
      install -v -D -m 644 $man /usr/share/$man
  done 
popd