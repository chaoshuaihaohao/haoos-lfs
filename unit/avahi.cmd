set +e
groupadd -fg 84 avahi &&
useradd -c "Avahi Daemon Owner" -d /var/run/avahi-daemon -u 84 \
        -g avahi -s /bin/false avahi

groupadd -fg 86 netdev
set -e

patch -Np1 -i $BLFS_SRC_DIR/avahi-0.8-ipv6_race_condition_fix-1.patch

./configure --prefix=/usr        \
            --sysconfdir=/etc    \
            --localstatedir=/var \
            --disable-static     \
            --disable-libevent   \
            --disable-mono       \
            --disable-monodoc    \
            --disable-python     \
            --disable-qt3        \
            --disable-qt4        \
            --enable-core-docs   \
            --with-distro=none   \
            --with-systemdsystemunitdir=/lib/systemd/system &&
make

make install -j1

systemctl enable avahi-daemon

systemctl enable avahi-dnsconfd
