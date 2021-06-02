mkdir build 
cd    build 

meson --prefix=/usr -Ddocs=false -Dman=false .. 
ninja

#ninja test

ninja install