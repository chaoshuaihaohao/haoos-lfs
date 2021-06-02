patch -Np1 -i $BLFS_SRC_DIR/bluez-5.55-upstream_fixes-1.patch

./configure --prefix=/usr         \
            --sysconfdir=/etc     \
            --localstatedir=/var  \
            --enable-library      
make

make install
ln -svf ../libexec/bluetooth/bluetoothd /usr/sbin

install -v -dm755 /etc/bluetooth 
install -v -m644 src/main.conf /etc/bluetooth/main.conf

install -v -dm755 /usr/share/doc/bluez-5.55 
install -v -m644 doc/*.txt /usr/share/doc/bluez-5.55


cat > /etc/bluetooth/rfcomm.conf << "EOF"
# Start rfcomm.conf
# Set up the RFCOMM configuration of the Bluetooth subsystem in the Linux kernel.
# Use one line per command
# See the rfcomm man page for options


# End of rfcomm.conf
EOF




cat > /etc/bluetooth/uart.conf << "EOF"
# Start uart.conf
# Attach serial devices via UART HCI to BlueZ stack
# Use one line per device
# See the hciattach man page for options

# End of uart.conf
EOF


systemctl enable bluetooth


#systemctl enable --global obex