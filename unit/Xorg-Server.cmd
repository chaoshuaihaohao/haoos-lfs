./configure $XORG_CONFIG            \
            --enable-glamor         \
            --enable-suid-wrapper   \
            --with-xkb-output=/var/lib/xkb &&
make
#make check

make install &&
mkdir -pv /etc/X11/xorg.conf.d