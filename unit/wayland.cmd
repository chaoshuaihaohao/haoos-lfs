./configure --prefix=/usr    \
            --disable-static \
            --disable-documentation 
make
#make check
make install -j1
