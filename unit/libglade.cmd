sed -i '/DG_DISABLE_DEPRECATED/d' glade/Makefile.in 
./configure --prefix=/usr --disable-static 
make

make install