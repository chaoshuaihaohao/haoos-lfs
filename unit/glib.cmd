patch -Np1 -i $BLFS_SRC_DIR/glib-2.66.7-skip_warnings-1.patch


if [ -e /usr/include/glib-2.0 ]; then
    rm -rf /usr/include/glib-2.0.old 
    mv -vf /usr/include/glib-2.0{,.old}
fi


mkdir build 
cd    build 
meson --prefix=/usr      \
      -Dman=true         \
      -Dselinux=disabled \
      ..                 
ninja


ninja install 
mkdir -p /usr/share/doc/glib-2.66.7 
cp -r ../docs/reference/{NEWS,gio,glib,gobject} /usr/share/doc/glib-2.66.7


rm -f /usr/include/glib-2.0/glib/gurifuncs.h