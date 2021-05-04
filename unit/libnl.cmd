./configure --prefix=/usr     \
            --sysconfdir=/etc \
            --disable-static  &&
make
make install
mkdir -vp /usr/share/doc/libnl-3.5.0 &&
tar -xf $BLFS_SRC_DIR/libnl-doc-3.5.0.tar.gz --strip-components=1 --no-same-owner \
    -C  /usr/share/doc/libnl-3.5.0