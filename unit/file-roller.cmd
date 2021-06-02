mkdir build 
cd    build 

meson --prefix=/usr -Dpackagekit=false .. 
ninja

ninja install 
chmod -v 0755 /usr/libexec/file-roller/isoinfo.sh