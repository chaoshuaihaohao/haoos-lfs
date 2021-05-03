./configure --prefix=/usr \
            --docdir=/usr/share/doc/gnutls-3.7.0 \
            --disable-guile \
            --with-default-trust-store-pkcs11="pkcs11:" &&
make
make install
make -C doc/reference install-data-local