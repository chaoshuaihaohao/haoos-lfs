mkdir build &&
cd    build    &&

meson --prefix=/usr \
      -Denable-gtk-doc=false .. &&
ninja
#ninja test
ninja install