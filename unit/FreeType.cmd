tar -xf $BLFS_SRC_DIR/freetype-doc-2.10.4.tar.xz --strip-components=2 -C docs

sed -ri "s:.*(AUX_MODULES.*valid):\1:" modules.cfg &&

sed -r "s:.*(#.*SUBPIXEL_RENDERING) .*:\1:" \
    -i include/freetype/config/ftoption.h  &&

./configure --prefix=/usr --enable-freetype-config --disable-static &&
make

make install

install -v -m755 -d /usr/share/doc/freetype-2.10.4 &&
cp -v -R docs/*     /usr/share/doc/freetype-2.10.4 &&
rm -v /usr/share/doc/freetype-2.10.4/freetype-config.1