sed -i -r '/^\s?testadobesdk/d' exempi/Makefile.am 
autoreconf -fiv


./configure --prefix=/usr --disable-static 
make

#make check

make install