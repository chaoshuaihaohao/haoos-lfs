patch -Np1 -i $BLFS_SRC_DIR/gpm-1.20.7-consolidated-1.patch 
./autogen.sh                                     
./configure --prefix=/usr --sysconfdir=/etc      
make

make install                                          

install-info --dir-file=/usr/share/info/dir           \
             /usr/share/info/gpm.info                 

ln -sfv libgpm.so.2.1.0 /usr/lib/libgpm.so            
install -v -m644 conf/gpm-root.conf /etc              

install -v -m755 -d /usr/share/doc/gpm-1.20.7/support 
install -v -m644    doc/support/*                     \
                    /usr/share/doc/gpm-1.20.7/support 
install -v -m644    doc/{FAQ,HACK_GPM,README*}        \
                    /usr/share/doc/gpm-1.20.7

rm -rf /lfs/blfs-systemd-units-20210122
tar xf $BLFS_SRC_DIR/blfs-systemd-units-20210122.tar.xz -C /lfs
pushd /lfs/blfs-systemd-units-20210122
make install-gpm
popd