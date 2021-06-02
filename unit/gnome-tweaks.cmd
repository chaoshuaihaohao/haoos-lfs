patch -Np1 -i $BLFS_SRC_DIR/gnome-tweaks-3.34.1-port_to_libhandy1-1.patch

mkdir build 
cd    build 

meson --prefix=/usr 
ninja

ninja install