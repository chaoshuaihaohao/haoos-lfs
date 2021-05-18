sed -i '/GZIP/s/^/#/' makefile

make

make doc_dir=/usr/share/doc/highlight-3.62/ gui

make doc_dir=/usr/share/doc/highlight-3.62/ install

make install-gui