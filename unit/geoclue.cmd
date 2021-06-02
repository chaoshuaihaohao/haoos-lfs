mkdir build 
pushd    build 

meson --prefix=/usr -Dgtk-doc=false .. 
ninja
ninja install
popd