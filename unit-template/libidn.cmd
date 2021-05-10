./configure --prefix=/usr --disable-static &&
make

make install

find doc -name "Makefile*" -delete
rm -rf -v doc/{gdoc,idn.1,stamp-vti,man,texi}
mkdir -v       /usr/share/doc/libidn-1.36
cp -r -v doc/* /usr/share/doc/libidn-1.36