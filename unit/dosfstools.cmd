#BLFS mkfs.fat command
./configure --prefix=/               \
            --enable-compat-symlinks \
            --mandir=/usr/share/man  \
            --docdir=/usr/share/doc/dosfstools-4.2 &&
make
make install