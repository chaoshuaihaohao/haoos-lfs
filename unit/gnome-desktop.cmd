mkdir build 
pushd build 

meson --prefix=/usr                 \
      -Dgnome_distributor="BLFS" .. 
ninja
ninja install

popd