./configure --prefix=/usr \
            --sysconfdir=/etc \
            --disable-orbit \
            --disable-static &&
make

make install -j1
ln -svf gconf.xml.defaults /etc/gconf/gconf.xml.system
