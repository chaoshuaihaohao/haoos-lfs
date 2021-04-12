#!/bin/bash
set -e
#Chapter 11. The End - Part 1
echo 10.1-systemd > /etc/lfs-release

cat > /etc/lsb-release << "EOF"
DISTRIB_ID="Linux From Scratch"
DISTRIB_RELEASE="10.1-systemd"
DISTRIB_CODENAME="haoos-0.1"
DISTRIB_DESCRIPTION="Linux From Scratch"
EOF

cat > /etc/os-release << "EOF"
NAME="Linux From Scratch"
VERSION="10.1-systemd"
ID=lfs
PRETTY_NAME="Linux From Scratch 10.1-systemd"
VERSION_CODENAME="haoos-0.1"
EOF

rm -rf /lfs /sources /lfs-sources.tar.gz /haoos /tools
#logout
exit
