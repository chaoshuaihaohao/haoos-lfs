./autogen.sh $XORG_CONFIG     \
            --enable-kms-only \
            --enable-uxa      \
            --mandir=/usr/share/man 
make


make install
      
mv -v /usr/share/man/man4/intel-virtual-output.4 \
      /usr/share/man/man1/intel-virtual-output.1
      
sed -i '/\.TH/s/4/1/' /usr/share/man/man1/intel-virtual-output.1
