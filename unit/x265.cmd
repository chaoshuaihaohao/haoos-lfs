mkdir bld 
cd    bld 

cmake -DCMAKE_INSTALL_PREFIX=/usr ../source 
make

make install 
rm -vf /usr/lib/libx265.a 