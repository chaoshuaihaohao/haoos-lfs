mkdir bld 
pushd bld 

meson --prefix=/usr -Dgtk_doc=false .. 
ninja
ninja install
popd