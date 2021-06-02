./configure --prefix=/usr                  \
            --shared-cares                 \
            --shared-libuv                 \
            --shared-openssl               \
            --shared-nghttp2               \
            --shared-zlib                  \
            --with-intl=system-icu         
make

#make test-only

make install
ln -sf node /usr/share/doc/node-14.16.0