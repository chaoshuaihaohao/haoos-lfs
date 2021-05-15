mkdir build &&
cd    build &&

meson --prefix=/usr      \
      -Dselinux=false    \
      -Dpackagekit=false \
      .. &&

ninja

#ninja test

ninja install