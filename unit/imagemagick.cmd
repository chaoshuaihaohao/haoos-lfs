./configure --prefix=/usr     \
            --sysconfdir=/etc \
            --enable-hdri     \
            --with-modules    \
            --with-perl       \
            --disable-static  
make


make DOCUMENTATION_PATH=/usr/share/doc/imagemagick-7.0.11 install -j1
