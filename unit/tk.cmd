pushd unix 
./configure --prefix=/usr \
            --mandir=/usr/share/man \
            $([ $(uname -m) = x86_64 ]  echo --enable-64bit) 

make 

sed -e "s@^\(TK_SRC_DIR='\).*@\1/usr/include'@" \
    -e "/TK_B/s@='\(-L\)\?.*unix@='\1/usr/lib@" \
    -i tkConfig.sh

#make test

make install 
make install-private-headers 
ln -v -sf wish8.6 /usr/bin/wish 
chmod -v 755 /usr/lib/libtk8.6.so

popd