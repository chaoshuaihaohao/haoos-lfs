patch -Np1 -i $BLFS_SRC_DIR/net-tools-CVS_20101030-remove_dups-1.patch &&
sed -i '/#include <netinet\/ip.h>/d'  iptunnel.c &&

yes "" | make config &&
make
make update