patch -Np1 -i $BLFS_SRC_DIR/libcanberra-0.30-wayland-1.patch

./configure --prefix=/usr --disable-oss 
make

make docdir=/usr/share/doc/libcanberra-0.30 install -j1
