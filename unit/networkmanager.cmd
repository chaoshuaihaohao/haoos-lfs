#If Qt-5.15.2 is installed and the Qt based examples are desired, fix two meson.build files:
sed -e 's/-qt4/-qt5/'              \
    -e 's/moc_location/host_bins/' \
    -i examples/C/qt/meson.build   

sed -e 's/Qt/&5/'                  \
    -i meson.build

sed '/initrd/d' -i src/core/meson.build

grep -rl '^#!.*python$' | xargs sed -i '1s/python/&3/'

mkdir build 
cd    build    

CXXFLAGS+="-O2 -fPIC"            \
meson --prefix /usr              \
      -Dlibaudit=no              \
      -Dlibpsl=false             \
      -Dnmtui=true               \
      -Dovs=false                \
      -Dppp=false                \
      -Dselinux=false            \
      -Dqt=false                 \
      -Dudev_dir=/lib/udev       \
      -Dsession_tracking=systemd \
      -Dmodem_manager=false      \
      -Dsystemdsystemunitdir=/lib/systemd/system \
      .. 
ninja


ninja install 
rm -rf /usr/share/doc/NetworkManager-1.30.0
mv -v /usr/share/doc/NetworkManager{,-1.30.0}

#Configuring NetworkManager
cat >> /etc/NetworkManager/NetworkManager.conf << "EOF"
[main]
plugins=keyfile
EOF

cat > /etc/NetworkManager/conf.d/polkit.conf << "EOF"
[main]
auth-polkit=true
EOF

cat > /etc/NetworkManager/conf.d/dhcp.conf << "EOF"
[main]
dhcp=dhclient
EOF

cat > /etc/NetworkManager/conf.d/no-dns-update.conf << "EOF"
[main]
dns=none
EOF

:<<!
groupadd -fg 86 netdev 
/usr/sbin/usermod -a -G netdev <username>

cat > /usr/share/polkit-1/rules.d/org.freedesktop.NetworkManager.rules << "EOF"
polkit.addRule(function(action, subject) {
    if (action.id.indexOf("org.freedesktop.NetworkManager.") == 0  subject.isInGroup("netdev")) {
        return polkit.Result.YES;
    }
});
EOF
!

systemctl enable NetworkManager

#该单元用于阻止需要网络连接的服务在NetworkManager建立连接之前启动
systemctl disable NetworkManager-wait-online
