rm -rf freetype lcms2mt jpeg libpng openjpeg

patch -Np1 -i $BLFS_SRC_DIR/ghostscript-9.53.3-freetype_fix-1.patch

rm -rf zlib &&

./configure --prefix=/usr           \
            --disable-compile-inits \
            --enable-dynamic        \
            --with-system-libtiff   &&
make

make so

make install

make soinstall &&
install -v -m644 base/*.h /usr/include/ghostscript &&
ln -sfvn ghostscript /usr/include/ps

mv -v /usr/share/doc/ghostscript/9.53.3 /usr/share/doc/ghostscript-9.53.3  &&
rm -rfv /usr/share/doc/ghostscript &&
cp -r examples/ /usr/share/ghostscript/9.53.3/

tar -xvf $BLFS_SRC_DIR/ghostscript-fonts-std-8.11.tar.gz -C /usr/share/ghostscript --no-same-owner &&
tar -xvf $BLFS_SRC_DIR/gnu-gs-fonts-other-6.0.tar.gz     -C /usr/share/ghostscript --no-same-owner &&
fc-cache -v /usr/share/ghostscript/fonts/


#gs -q -dBATCH /usr/share/ghostscript/9.53.3/examples/tiger.eps