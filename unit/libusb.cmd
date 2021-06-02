./configure --prefix=/usr --disable-static 
make
#sed -i "s/^TCL_SUBST/#&/; s/wide//" doc/doxygen.cfg 
#make -C doc docs
make install
install -v -d -m755 /usr/share/doc/libusb-1.0.24/apidocs #
#install -v -m644    doc/html/* \
#                    /usr/share/doc/libusb-1.0.24/apidocs