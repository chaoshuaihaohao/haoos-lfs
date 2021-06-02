./configure --prefix=/usr --disable-static 
make
doxygen doc/doxygen.conf
make install
install -v -dm755 /usr/share/doc/libisofs-1.5.4 
install -v -m644 doc/html/* /usr/share/doc/libisofs-1.5.4