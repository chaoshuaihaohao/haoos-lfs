mkdir build 
pushd    build 

meson --prefix=/usr -Dgtk_doc=false -Dalways_build_tests=false .. 
ninja
ninja install

popd