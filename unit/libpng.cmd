gzip -cd $BLFS_SRC_DIR/libpng-1.6.37-apng.patch.gz | patch -p1

./configure --prefix=/usr --disable-static &&
make

#make check

make install &&
mkdir -vp /usr/share/doc/libpng-1.6.37 &&
cp -v README libpng-manual.txt /usr/share/doc/libpng-1.6.37