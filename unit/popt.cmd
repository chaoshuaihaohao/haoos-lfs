./configure --prefix=/usr --disable-static &&
make

sed -i 's@\./@src/@' Doxyfile &&
doxygen

#make check

make install

install -v -m755 -d /usr/share/doc/popt-1.18 &&
install -v -m644 doxygen/html/* /usr/share/doc/popt-1.18