mkdir build 
pushd    build 

meson --prefix=/usr -Denable-docs=false .. 
ninja
ninja install
popd