install  -v -m700 -d /var/lib/dhcpcd 

groupadd -g 52 dhcpcd        
useradd  -c 'dhcpcd PrivSep' \
         -d /var/lib/dhcpcd  \
         -g dhcpcd           \
         -s /bin/false     \
         -u 52 dhcpcd 
chown    -v dhcpcd:dhcpcd /var/lib/dhcpcd
./configure --libexecdir=/lib/dhcpcd \
            --dbdir=/var/lib/dhcpcd  \
            --privsepuser=dhcpcd     
make
#make test
make install