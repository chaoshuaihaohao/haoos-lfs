./configure --prefix=/usr                \
            --enable-compile-warnings=no \
            --enable-cxx-warnings=no     &&
make


make install -j1
