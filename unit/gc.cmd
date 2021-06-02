./configure --prefix=/usr      \
            --enable-cplusplus \
            --disable-static   \
            --docdir=/usr/share/doc/gc-8.0.4 
make

#make check

make install
install -v -m644 doc/gc.man /usr/share/man/man3/gc_malloc.3