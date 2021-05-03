./configure --prefix=/usr          \
            --sysconfdir=/etc/lynx \
            --datadir=/usr/share/doc/lynx-2.8.9rel.1 \
            --with-zlib            \
            --with-bzlib           \
            --with-ssl             \
            --with-screen=ncursesw \
            --enable-locale-charset &&
make
make install-full &&
chgrp -v -R root /usr/share/doc/lynx-2.8.9rel.1/lynx_doc
#配置lynx
sed -e '/#LOCALE/     a LOCALE_CHARSET:TRUE'     \
    -i /etc/lynx/lynx.cfg
sed -e '/#DEFAULT_ED/ a DEFAULT_EDITOR:vi'       \
    -i /etc/lynx/lynx.cfg
sed -e '/#PERSIST/    a PERSISTENT_COOKIES:TRUE' \
    -i /etc/lynx/lynx.cfg