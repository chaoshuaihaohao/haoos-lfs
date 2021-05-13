mkdir gtkmm3-build &&
cd    gtkmm3-build &&

meson --prefix=/usr \
      ..           &&

ninja

ninja install

#mv -v /usr/share/doc/gtkmm-3.0 /usr/share/doc/gtkmm-3.24.3