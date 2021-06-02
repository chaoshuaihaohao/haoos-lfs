./configure --prefix=/usr --disable-static 
make

doxygen Doxyfile

#make verify

make install

#install -v -m755 -d /usr/share/doc/libevent-2.1.12/api 
#cp      -v -R       doxygen/html/* \
#                    /usr/share/doc/libevent-2.1.12/api