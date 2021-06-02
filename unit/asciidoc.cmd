sed -i 's:doc/testasciidoc.1::' Makefile.in 
rm doc/testasciidoc.1.txt
./configure --prefix=/usr     \
            --sysconfdir=/etc \
            --docdir=/usr/share/doc/asciidoc-9.1.0 
make
make install 
make docs