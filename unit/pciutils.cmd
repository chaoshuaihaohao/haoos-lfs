make PREFIX=/usr                \
     SHAREDIR=/usr/share/hwdata \
     SHARED=yes

make PREFIX=/usr                \
     SHAREDIR=/usr/share/hwdata \
     SHARED=yes                 \
     install install-lib        

chmod -v 755 /usr/lib/libpci.so
update-pciids

cat > /lib/systemd/system/update-pciids.service << "EOF" 
[Unit]
Description=Update pci.ids file
Documentation=man:update-pciids(8)
DefaultDependencies=no
After=local-fs.target network-online.target
Before=shutdown.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/sbin/update-pciids
EOF
cat > /lib/systemd/system/update-pciids.timer << "EOF" 
[Unit]
Description=Update pci.ids file weekly

[Timer]
OnCalendar=Sun 02:30:00
Persistent=true

[Install]
WantedBy=timers.target
EOF
systemctl enable update-pciids.timer
