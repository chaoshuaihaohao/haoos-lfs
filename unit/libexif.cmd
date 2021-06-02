patch -Np1 -i $BLFS_SRC_DIR/libexif-0.6.22-security_fixes-1.patch

./configure --prefix=/usr    \
            --disable-static \
            --with-doc-dir=/usr/share/doc/libexif-0.6.22 
make

make install