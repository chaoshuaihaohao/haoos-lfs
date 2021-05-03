patch -p1 -i $BLFS_SRC_DIR/libxml2-2.9.10-security_fixes-1.patch

sed -i '/if Py/{s/Py/(Py/;s/)/))/}' python/{types.c,libxml.c}

sed -i 's/test.test/#&/' python/tests/tstLastError.py

sed -i 's/ TRUE/ true/' encoding.c

./configure --prefix=/usr    \
            --disable-static \
            --with-history   \
            --with-python=/usr/bin/python3 &&
make

#tar xf $BLFS_SRC_DIR/xmlts20130923.tar.gz -C /lfs
#systemctl stop httpd.service

make install
