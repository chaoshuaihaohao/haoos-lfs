./configure --prefix=/usr    \
            --enable-vala    \
            --disable-static \
            --docdir=/usr/share/doc/librsvg-2.50.3 &&
make
#make check
make install