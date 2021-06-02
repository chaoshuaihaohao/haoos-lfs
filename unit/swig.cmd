./configure --prefix=/usr \
            --without-maximum-compile-warnings 
make

make install 
install -v -m755 -d /usr/share/doc/swig-4.0.2 
cp -v -R Doc/* /usr/share/doc/swig-4.0.2