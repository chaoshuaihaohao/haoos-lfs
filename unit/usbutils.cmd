./autogen.sh --prefix=/usr --datadir=/usr/share/hwdata 
make
make install
install -dm755 /usr/share/hwdata/ 
wget http://www.linux-usb.org/usb.ids -O /usr/share/hwdata/usb.ids