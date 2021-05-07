tar -xf $BLFS_SRC_DIR/nasm-2.15.05-xdoc.tar.xz --strip-components=1

./configure --prefix=/usr &&
make

make install

install -m755 -d         /usr/share/doc/nasm-2.15.05/html  &&
cp -v doc/html/*.html    /usr/share/doc/nasm-2.15.05/html  &&
cp -v doc/*.{txt,ps,pdf} /usr/share/doc/nasm-2.15.05