#BLFS cpio,Linux compile need cpio

sed -i '/The name/,+2 d' src/global.c
./configure --prefix=/usr \
            --bindir=/bin \
            --enable-mt   \
            --with-rmt=/usr/libexec/rmt 
make 
makeinfo --html            -o doc/html      doc/cpio.texi 
makeinfo --html --no-split -o doc/cpio.html doc/cpio.texi 
makeinfo --plaintext       -o doc/cpio.txt  doc/cpio.texi

#make -C doc pdf 
#make -C doc ps


make install 
install -v -m755 -d /usr/share/doc/cpio-2.13/html 
install -v -m644    doc/html/* \
                    /usr/share/doc/cpio-2.13/html 
install -v -m644    doc/cpio.{html,txt} \
                    /usr/share/doc/cpio-2.13
#install -v -m644 doc/cpio.{pdf,ps,dvi} \
#                 /usr/share/doc/cpio-2.13
