mkdir build 
pushd    build 

meson --prefix=/usr          \
      -Dlibproxy=disabled .. 
ninja
#ninja test
ninja install
popd