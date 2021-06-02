./configure --prefix=/usr                        \
            --disable-static                     \
            --docdir=/usr/share/doc/potrace-1.16 \
            --enable-a4                          \
            --enable-metric                      \
            --with-libpotrace                    
make

#make check

make install