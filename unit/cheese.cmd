sed -i "s/&version;/3.38.0/" docs/reference/cheese{,-docs}.xml


mkdir build &&
cd    build &&

meson --prefix=/usr -Dgtk_doc=false .. &&
ninja

ninja install