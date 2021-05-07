./configure --prefix=/usr --disable-static &&
make
#make check

make install                                   &&
rm -rf /usr/include/enchant                    &&
ln -sfv enchant-2       /usr/include/enchant   &&
ln -sfv enchant-2       /usr/bin/enchant       &&
ln -sfv libenchant-2.so /usr/lib/libenchant.so &&
ln -sfv enchant-2.pc    /usr/lib/pkgconfig/enchant.pc