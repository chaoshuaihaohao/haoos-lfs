sed -i 's:"/desktop:"/org:' schema/*.xml &&

./configure --prefix=/usr     \
            --sysconfdir=/etc \
            --with-pam-dir=/lib/security &&
make
#make check
make install