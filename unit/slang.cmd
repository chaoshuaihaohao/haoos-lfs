./configure --prefix=/usr \
            --sysconfdir=/etc \
            --with-readline=gnu &&
make -j1

#make check

make install_doc_dir=/usr/share/doc/slang-2.3.2   \
     SLSH_DOC_DIR=/usr/share/doc/slang-2.3.2/slsh \
     install-all -j1&&

chmod -v 755 /usr/lib/libslang.so.2.3.2 \
             /usr/lib/slang/v2/modules/*.so