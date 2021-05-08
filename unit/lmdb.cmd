cd libraries/liblmdb &&
make                 &&
sed -i 's| liblmdb.a||' Makefile

make prefix=/usr install