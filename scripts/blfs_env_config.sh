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

popd #LFS
