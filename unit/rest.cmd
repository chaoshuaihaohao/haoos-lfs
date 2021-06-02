./configure --prefix=/usr \
    --with-ca-certificates=/etc/pki/tls/certs/ca-bundle.crt 
make
make install -j1
