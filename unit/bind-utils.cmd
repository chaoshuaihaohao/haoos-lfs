./configure --prefix=/usr --without-python 
make -C lib/dns    
make -C lib/isc    
make -C lib/bind9  
make -C lib/isccfg 
make -C lib/irs    
make -C bin/dig    
make -C doc

make -C bin/dig install 
cp -v doc/man/{dig.1,host.1,nslookup.1} /usr/share/man/man1