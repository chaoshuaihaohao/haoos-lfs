./configure $XORG_CONFIG \
            --with-udev-rules-dir=/lib/udev/rules.d \
            --with-systemd-unit-dir=/lib/systemd/system 
make
#make check
make install