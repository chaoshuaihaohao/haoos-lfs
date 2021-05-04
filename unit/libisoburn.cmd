./configure --prefix=/usr              \
            --disable-static           \
            --enable-pkg-check-modules &&
make
#doxygen doc/doxygen.conf
make install
install -v -dm755 /usr/share/doc/libisoburn-1.5.4 &&
#install -v -m644 doc/html/* /usr/share/doc/libisoburn-1.5.4