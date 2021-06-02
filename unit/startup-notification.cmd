./configure --prefix=/usr --disable-static 
make

make install
install -v -m644 -D doc/startup-notification.txt \
    /usr/share/doc/startup-notification-0.12/startup-notification.txt