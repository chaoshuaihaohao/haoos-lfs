./configure --prefix=/usr 
make
sed -i '/^LN_S/s/s/sfvn/' */Makefile
make install