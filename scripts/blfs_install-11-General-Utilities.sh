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

rm -rf asciidoc-9.1.0
tar xf $BLFS_SRC_DIR/asciidoc-9.1.0.tar.gz
pushd asciidoc-9.1.0
sed -i 's:doc/testasciidoc.1::' Makefile.in &&
rm doc/testasciidoc.1.txt
./configure --prefix=/usr     \
            --sysconfdir=/etc \
            --docdir=/usr/share/doc/asciidoc-9.1.0 &&
make
make install &&
make docs
popd
rm -rf asciidoc-9.1.0



popd #LFS
