./configure --prefix=/usr                 \
            --sysconfdir=/etc             \
            --localstatedir=/var          \
            --with-systemd-journal        \
            --with-systemd-suspend-resume \
            --disable-static &&
make
#make check
make install
systemctl enable ModemManager