./configure &&
make
make doc
#make check
make install
install -v -d -m755 /usr/share/doc/alsa-lib-1.2.4/html/search &&
install -v -m644 doc/doxygen/html/*.* \
                /usr/share/doc/alsa-lib-1.2.4/html &&
install -v -m644 doc/doxygen/html/search/* \
                /usr/share/doc/alsa-lib-1.2.4/html/search