autoreconf -fiv              
./configure --prefix=/usr    \
            --without-python 
make

make install