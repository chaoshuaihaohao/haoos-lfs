#!/bin/sh
set -e
#
if [ `id -u` != 0 ];then
        echo Permission delay, Please run as root!
        exit
fi

if [ -n $JOBS ];then
        JOBS=`grep -c ^processor /proc/cpuinfo 2>/dev/null`
        if [ ! $JOBS ];then
                JOBS="1"
        fi
fi
export MAKEFLAGS=-j$JOBS
export BLFS_SRC_DIR=/sources/blfs-sources
pushd /lfs


export ETH=ens3
#网桥配置
cat > /etc/systemd/network/50-br0.netdev << EOF
[NetDev]
Name=br0
Kind=bridge
EOF

cat > /etc/systemd/network/51-eth0.network << EOF
[Match]
Name=$ETH

[Network]
Bridge=br0
EOF

cat > /etc/systemd/network/60-br0.network << EOF
[Match]
Name=br0

[Network]
DHCP=yes
EOF

cat > /etc/systemd/network/60-br0.network << EOF
[Match]
Name=br0

[Network]
Address=192.168.0.2/24
Gateway=192.168.0.1
DNS=192.168.0.1
EOF

systemctl restart systemd-networkd

rm -rf dhcpcd-9.4.0
tar xf $BLFS_SRC_DIR/dhcpcd-9.4.0.tar.xz
pushd dhcpcd-9.4.0
install  -v -m700 -d /var/lib/dhcpcd &&

groupadd -g 52 dhcpcd        &&
useradd  -c 'dhcpcd PrivSep' \
         -d /var/lib/dhcpcd  \
         -g dhcpcd           \
         -s /bin/false     \
         -u 52 dhcpcd &&
chown    -v dhcpcd:dhcpcd /var/lib/dhcpcd
./configure --libexecdir=/lib/dhcpcd \
            --dbdir=/var/lib/dhcpcd  \
            --privsepuser=dhcpcd     &&
make
#make test
make install
popd

#配置DHCP服务器为守护进程，桌面系统这里不需要
#rm -rf blfs-systemd-units-20210122
#tar xf $BLFS_SRC_DIR/blfs-systemd-units-20210122.tar.xz
#pushd blfs-systemd-units-20210122
#make install-dhcpcd
#systemctl start dhcpcd@eth0
#systemctl enable dhcpcd@eth0
#popd

rm -rf dhcp-4.4.2
tar xf $BLFS_SRC_DIR/dhcp-4.4.2.tar.gz
pushd dhcp-4.4.2
sed -i '/o.*dhcp_type/d' server/mdb.c &&
sed -r '/u.*(local|remote)_port/d'    \
    -i client/dhclient.c              \
       relay/dhcrelay.c
( export CFLAGS="${CFLAGS:--g -O2} -Wall -fno-strict-aliasing                 \
        -D_PATH_DHCLIENT_SCRIPT='\"/sbin/dhclient-script\"'         \
        -D_PATH_DHCPD_CONF='\"/etc/dhcp/dhcpd.conf\"'               \
        -D_PATH_DHCLIENT_CONF='\"/etc/dhcp/dhclient.conf\"'"        &&

./configure --prefix=/usr                                           \
            --sysconfdir=/etc/dhcp                                  \
            --localstatedir=/var                                    \
            --with-srv-lease-file=/var/lib/dhcpd/dhcpd.leases       \
            --with-srv6-lease-file=/var/lib/dhcpd/dhcpd6.leases     \
            --with-cli-lease-file=/var/lib/dhclient/dhclient.leases \
            --with-cli6-lease-file=/var/lib/dhclient/dhclient6.leases
) &&
make -j1

make -C client install         &&
mv -v /usr/sbin/dhclient /sbin &&
install -v -m755 client/scripts/linux /sbin/dhclient-script

#make -C server install

#make install                   &&
#mv -v /usr/sbin/dhclient /sbin &&
#install -v -m755 client/scripts/linux /sbin/dhclient-script

#DHCP客户端配置
install -vdm755 /etc/dhcp &&
cat > /etc/dhcp/dhclient.conf << "EOF"
# Begin /etc/dhcp/dhclient.conf
#
# Basic dhclient.conf(5)

#prepend domain-name-servers 127.0.0.1;
request subnet-mask, broadcast-address, time-offset, routers,
        domain-name, domain-name-servers, domain-search, host-name,
        netbios-name-servers, netbios-scope, interface-mtu,
        ntp-servers;
require subnet-mask, domain-name-servers;
#timeout 60;
#retry 60;
#reboot 10;
#select-timeout 5;
#initial-interval 2;

# End /etc/dhcp/dhclient.conf
EOF

install -v -dm 755 /var/lib/dhclient

rm -rf blfs-systemd-units-20210122
tar xf $BLFS_SRC_DIR/blfs-systemd-units-20210122.tar.xz
pushd blfs-systemd-units-20210122
make install-dhclient
systemctl start dhclient@$ETH
systemctl enable dhclient@$ETH
popd

#DHCP服务器配置
:<<eof
cat > /etc/dhcp/dhcpd.conf << "EOF"
# Begin /etc/dhcp/dhcpd.conf
#
# Example dhcpd.conf(5)

# Use this to enable / disable dynamic dns updates globally.
ddns-update-style none;

# option definitions common to all supported networks...
option domain-name "example.org";
option domain-name-servers ns1.example.org, ns2.example.org;

default-lease-time 600;
max-lease-time 7200;

# This is a very basic subnet declaration.
subnet 10.254.239.0 netmask 255.255.255.224 {
  range 10.254.239.10 10.254.239.20;
  option routers rtr-239-0-1.example.org, rtr-239-0-2.example.org;
}

# End /etc/dhcp/dhcpd.conf
EOF

install -v -dm 755 /var/lib/dhcpd
rm -rf blfs-systemd-units-20210122
tar xf $BLFS_SRC_DIR/blfs-systemd-units-20210122.tar.xz
pushd blfs-systemd-units-20210122
make install-dhcpd
popd
eof


popd #LFS
