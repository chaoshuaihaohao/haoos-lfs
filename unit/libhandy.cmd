mkdir build 
cd    build 

meson --prefix=/usr .. 
ninja
ninja install