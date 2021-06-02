CXX="/usr/bin/g++"              \
./configure --prefix=/usr       \
            --enable-shared     \
            --with-system-expat \
            --with-system-ffi   \
            --with-ensurepip=yes 
make

#make check

make install -j1

#ln -svfn python-3.9.2 /usr/share/doc/python-3

#export PYTHONDOCS=/usr/share/doc/python-3/html
