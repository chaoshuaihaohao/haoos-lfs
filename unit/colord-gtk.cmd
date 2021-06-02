mkdir build 
cd    build 

meson --prefix=/usr  \
      -Dgtk2=true    \
      -Dvapi=true    \
      -Ddocs=false   \
      -Dman=false .. 
ninja
#ninja test
ninja install