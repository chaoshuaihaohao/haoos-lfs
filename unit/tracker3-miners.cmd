rm -v -rf /etc/xdg/autostart/tracker-miner-*

mkdir build &&
cd    build &&

meson --prefix=/usr -Dman=false .. &&
ninja

#ninja test

ninja install