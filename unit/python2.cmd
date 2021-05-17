sed -i '/2to3/d' ./setup.py


./configure --prefix=/usr       \
            --enable-shared     \
            --with-system-expat \
            --with-system-ffi   \
            --enable-unicode=ucs4 &&
make

#make -k test


make altinstall                               
ln -s python2.7        /usr/bin/python2        &&
ln -s python2.7-config /usr/bin/python2-config &&
chmod -v 755 /usr/lib/libpython2.7.so.1.0


#install -v -dm755 /usr/share/doc/python-2.7.18 &&

#tar --strip-components=1                     \
#    --no-same-owner                          \
#    --directory /usr/share/doc/python-2.7.18 \
#    -xvf $BLFS_SRC_DIR/python-2.7.18-docs-html.tar.bz2 &&

#find /usr/share/doc/python-2.7.18 -type d -exec chmod 0755 {} \; &&
#find /usr/share/doc/python-2.7.18 -type f -exec chmod 0644 {} \;