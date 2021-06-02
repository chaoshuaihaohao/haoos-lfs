./configure --prefix=/usr              \
            --sysconfdir=/etc          \
            --enable-broadway-backend  \
            --enable-x11-backend       \
            --enable-wayland-backend   
make
make install