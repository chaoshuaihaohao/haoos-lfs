patch -Np1 -i $BLFS_SRC_DIR/gnome-nettool-3.8.1-ping_and_netstat_fixes-1.patch


./configure --prefix=/usr &&
make


make install