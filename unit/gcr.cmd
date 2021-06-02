sed -i 's:"/desktop:"/org:' schema/*.xml 

mkdir gcr-build 
pushd    gcr-build 

meson --prefix=/usr -Dgtk_doc=false .. 
ninja
#ninja test
ninja install

popd