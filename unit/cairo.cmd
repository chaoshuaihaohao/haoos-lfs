autoreconf -fv              &&
./configure --prefix=/usr    \
            --disable-static \
            --enable-tee &&
make
make install