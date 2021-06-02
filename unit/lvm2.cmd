SAVEPATH=$PATH                  
PATH=$PATH:/sbin:/usr/sbin      
./configure --prefix=/usr       \
            --exec-prefix=      \
            --enable-cmdlib     \
            --enable-pkgconfig  \
            --enable-udev_sync  
make                            
PATH=$SAVEPATH                  
unset SAVEPATH

make -C tools install_tools_dynamic 
make -C udev  install                 
make -C libdm install

#make S=shell/thin-flags.sh check_local

make install
make install_systemd_units