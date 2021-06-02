mkdir gjs-build 
pushd    gjs-build 

meson --prefix=/usr .. 
ninja

#ninja test

ninja install 
ln -sfv gjs-console /usr/bin/gjs

popd