mkdir build &&
cd    build &&

meson --prefix=/usr                             \
      -Dgtk_doc=false                           \
      -Dmobile_broadband_provider_info=false .. &&
ninja

ninja install