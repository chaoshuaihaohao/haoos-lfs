./configure --prefix=/usr \
            --sysconfdir=/etc \
            --disable-orbit \
            --disable-static &&
make

make install &&
ln -s gconf.xml.defaults /etc/gconf/gconf.xml.system