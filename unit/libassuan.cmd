rm -rf libassuan-2.5.4
tar xf $BLFS_SRC_DIR/libassuan-2.5.4.tar.bz2
pushd libassuan-2.5.4

./configure --prefix=/usr &&
make                      &&

make -C doc html                                                       &&
makeinfo --html --no-split -o doc/assuan_nochunks.html doc/assuan.texi &&
makeinfo --plaintext       -o doc/assuan.txt           doc/assuan.texi

#make -C doc pdf ps
make install &&
install -v -dm755   /usr/share/doc/libassuan-2.5.4/html &&
install -v -m644 doc/assuan.html/* \
                    /usr/share/doc/libassuan-2.5.4/html &&
install -v -m644 doc/assuan_nochunks.html \
                    /usr/share/doc/libassuan-2.5.4      &&
#install -v -m644 doc/assuan.{txt,texi} \
#                    /usr/share/doc/libassuan-2.5.4
#install -v -m644  doc/assuan.{pdf,ps,dvi} \
#                   /usr/share/doc/libassuan-2.5.4

popd
rm -rf libassuan-2.5.4
