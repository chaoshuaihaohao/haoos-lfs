./configure --prefix=/usr --disable-static &&
make

make -C doc doxygen

make docdir=/usr/share/doc/libdaemon-0.14 install

install -v -m755 -d /usr/share/doc/libdaemon-0.14/reference/html &&
install -v -m644 doc/reference/html/* /usr/share/doc/libdaemon-0.14/reference/html &&
install -v -m644 doc/reference/man/man3/* /usr/share/man/man3