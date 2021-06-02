echo "^samba4.rpc.echo.*on.*ncacn_np.*with.*object.*nt4_dc" >> selftest/knownfail

CFLAGS="-I/usr/include/tirpc"          \
LDFLAGS="-ltirpc"                      \
./configure                            \
    --prefix=/usr                      \
    --sysconfdir=/etc                  \
    --localstatedir=/var               \
    --with-piddir=/run/samba           \
    --with-pammodulesdir=/lib/security \
    --enable-fhs                       \
    --without-ad-dc                    \
    --enable-selftest                  
make

mkdir -vp /run/lock 
make install

mv -v /usr/lib/libnss_win{s,bind}.so.*  /lib                       
ln -v -sf ../../lib/libnss_winbind.so.2 /usr/lib/libnss_winbind.so 
ln -v -sf ../../lib/libnss_wins.so.2    /usr/lib/libnss_wins.so    

install -v -m644    examples/smb.conf.default /etc/samba

mkdir -pv /etc/openldap/schema

install -v -m644    examples/LDAP/README              \
                    /etc/openldap/schema/README.LDAP

install -v -m644    examples/LDAP/samba*              \
                    /etc/openldap/schema

install -v -m755    examples/LDAP/{get*,ol*} \
                    /etc/openldap/schema


install -dvm 755 /usr/lib/cups/backend 
ln -v -sf /usr/bin/smbspool /usr/lib/cups/backend/smb