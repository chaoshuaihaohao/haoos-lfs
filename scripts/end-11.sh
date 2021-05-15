#!/bin/bash
set -e
#Chapter 11. The End - Part 1
echo haoos-0.2 > /etc/haoos-release

cat > /etc/lsb-release << "EOF"
DISTRIB_ID="Linux haoos"
DISTRIB_RELEASE="haoos-0.2"
DISTRIB_CODENAME="haoos-0.2"
DISTRIB_DESCRIPTION="Linux haoos"
EOF

cat > /etc/os-release << "EOF"
NAME="Linux haoos"
VERSION="haoos-0.2"
ID=lfs
PRETTY_NAME="haoos 0.2"
VERSION_CODENAME="haoos-0.2"
EOF

#rm -rf /lfs /sources /lfs-sources.tar.gz /haoos /tools
#logout
exit
