./configure --prefix=/usr     \
            --disable-static  \
            --enable-lib-only \
            --docdir=/usr/share/doc/nghttp2-1.43.0 
make

make install