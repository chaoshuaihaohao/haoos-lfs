sed -i 's@/desktop/ibus@/org/freedesktop/ibus@g' \
    data/dconf/org.freedesktop.ibus.gschema.xml

./configure --prefix=/usr             \
            --sysconfdir=/etc         \
            --disable-unicode-dict    \
            --disable-emoji-dict      
rm -f tools/main.c                    
make

make install
gzip -dfv /usr/share/man/man{{1,5}/ibus*.gz,5/00-upstream-settings.5.gz}