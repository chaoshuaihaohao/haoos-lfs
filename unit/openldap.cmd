patch -Np1 -i $BLFS_SRC_DIR/openldap-2.4.57-consolidated-1.patch &&
autoconf &&

./configure --prefix=/usr     \
            --sysconfdir=/etc \
            --disable-static  \
            --enable-dynamic  \
            --disable-debug   \
            --disable-slapd &&

make depend &&
make

make install