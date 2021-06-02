./configure --prefix=/usr --disable-static 
make
#make check
make install -j1
install -v -m644 doc/Vorbis* /usr/share/doc/libvorbis-1.3.7
