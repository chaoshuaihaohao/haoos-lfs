./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/libsndfile-1.0.31 &&
make
#make check
make install