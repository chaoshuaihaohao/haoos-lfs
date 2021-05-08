./configure --prefix=/usr     \
            --sysconfdir=/etc \
            --with-python3    \
            --without-gtk-doc \
            --without-nvdimm  \
            --without-dm      &&
make
make install