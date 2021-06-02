mkdir build 
cd    build 

meson --prefix=/usr -Dlibportal=false .. 
ninja

ninja install

update-desktop-database