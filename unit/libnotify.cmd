mkdir build 
pushd    build 

meson --prefix=/usr -Dgtk_doc=false -Dman=false .. 
ninja
ninja install

popd