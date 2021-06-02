mkdir build 
cd    build 

meson --prefix=/usr -Dbuildtype=release .. 
ninja

#ninja test

ninja install