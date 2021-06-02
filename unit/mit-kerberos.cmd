cd src 

sed -i -e 's@\^u}@^u cols 300}@' tests/dejagnu/config/default.exp     
sed -i -e '/eq 0/{N;s/12 //}'    plugins/kdb/db2/libdb2/test/run.test 
sed -i '/t_iprop.py/d'           tests/Makefile.in                    

./configure --prefix=/usr            \
            --sysconfdir=/etc        \
            --localstatedir=/var/lib \
            --runstatedir=/run       \
            --with-system-et         \
            --with-system-ss         \
            --with-system-verto=no   \
            --enable-dns-for-realm 
make


make install 

for f in gssapi_krb5 gssrpc k5crypto kadm5clnt kadm5srv \
         kdb5 kdb_ldap krad krb5 krb5support verto ; do

    find /usr/lib -type f -name "lib$f*.so*" -exec chmod -v 755 {} \;    
done          

mv -v /usr/lib/libkrb5.so.3*        /lib 
mv -v /usr/lib/libk5crypto.so.3*    /lib 
mv -v /usr/lib/libkrb5support.so.0* /lib 

ln -v -sf ../../lib/libkrb5.so.3.3        /usr/lib/libkrb5.so        
ln -v -sf ../../lib/libk5crypto.so.3.1    /usr/lib/libk5crypto.so    
ln -v -sf ../../lib/libkrb5support.so.0.1 /usr/lib/libkrb5support.so 

mv -v /usr/bin/ksu /bin 
chmod -v 755 /bin/ksu   

#install -v -dm755 /usr/share/doc/krb5-1.19.1 
#cp -vfr ../doc/*  /usr/share/doc/krb5-1.19.1


cat > /etc/krb5.conf << "EOF"
# Begin /etc/krb5.conf

[libdefaults]
    default_realm = <EXAMPLE.ORG>
    encrypt = true

[realms]
    <EXAMPLE.ORG> = {
        kdc = <belgarath.example.org>
        admin_server = <belgarath.example.org>
        dict_file = /usr/share/dict/words
    }

[domain_realm]
    .<example.org> = <EXAMPLE.ORG>

[logging]
    kdc = SYSLOG:INFO:AUTH
    admin_server = SYSLOG:INFO:AUTH
    default = SYSLOG:DEBUG:DAEMON

# End /etc/krb5.conf
EOF