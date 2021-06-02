grep -rl '#!.*python$' | xargs sed -i '1s/python/&3/'
./configure --prefix=/usr                           \
            --disable-static                        \
            --enable-threaded-resolver              \
            --with-ca-path=/etc/ssl/certs 
make
make install 
rm -rf docs/examples/.deps 
find docs \( -name Makefile\* -o -name \*.1 -o -name \*.3 \) -exec rm {} \; 
install -v -d -m755 /usr/share/doc/curl-7.75.0 
cp -v -R docs/*     /usr/share/doc/curl-7.75.0