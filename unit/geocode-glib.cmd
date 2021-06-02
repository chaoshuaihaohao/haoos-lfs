mkdir build                                   
pushd    build                                   
meson --prefix /usr -Denable-gtk-doc=false .. 
ninja
#LANG=C ninja test
ninja install
popd