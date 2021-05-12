./autogen.sh $XORG_CONFIG     \
            --enable-kms-only \
            --enable-uxa      \
            --mandir=/usr/share/man &&
make


make install
      
mv -v /usr/share/man/man4/intel-virtual-output.4 \
      /usr/share/man/man1/intel-virtual-output.1
      
sed -i '/\.TH/s/4/1/' /usr/share/man/man1/intel-virtual-output.1


cat >> /etc/X11/xorg.conf.d/20-intel.conf << "EOF"
Section   "Device"
        Identifier "Intel Graphics"
        Driver     "intel"
        #Option     "DRI" "2"            # DRI3 is default
        #Option     "AccelMethod"  "sna" # default
        #Option     "AccelMethod"  "uxa" # fallback
EndSection
EOF