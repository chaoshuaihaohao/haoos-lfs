./configure --prefix=/usr --disable-static &&
make &&

make -C doc html                                       &&
makeinfo --html      -o doc/html       doc/parted.texi &&
makeinfo --plaintext -o doc/parted.txt doc/parted.texi


#make check

make install &&
install -v -m755 -d /usr/share/doc/parted-3.4/html &&
install -v -m644    doc/html/* \
                    /usr/share/doc/parted-3.4/html &&
install -v -m644    doc/{FAT,API,parted.{txt,html}} \
                    /usr/share/doc/parted-3.4

#install -v -m644 doc/FAT doc/API doc/parted.{pdf,ps,dvi} \
#                    /usr/share/doc/parted-3.4