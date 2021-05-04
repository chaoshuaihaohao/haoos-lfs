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

rm -rf libburn-1.5.4
tar xf $BLFS_SRC_DIR/libburn-1.5.4.tar.gz
pushd libburn-1.5.4
./configure --prefix=/usr --disable-static &&
make
#doxygen doc/doxygen.conf
make install
install -v -dm755 /usr/share/doc/libburn-1.5.4 &&
#install -v -m644 doc/html/* /usr/share/doc/libburn-1.5.4
popd
rm -rf libburn-1.5.4

rm -rf libisofs-1.5.4
tar xf $BLFS_SRC_DIR/libisofs-1.5.4.tar.gz
pushd libisofs-1.5.4
./configure --prefix=/usr --disable-static &&
make
#doxygen doc/doxygen.conf
make install
install -v -dm755 /usr/share/doc/libisofs-1.5.4 &&
#install -v -m644 doc/html/* /usr/share/doc/libisofs-1.5.4
popd
rm -rf libisofs-1.5.4

rm -rf libisoburn-1.5.4
tar xf $BLFS_SRC_DIR/libisoburn-1.5.4.tar.gz
pushd libisoburn-1.5.4
./configure --prefix=/usr              \
            --disable-static           \
            --enable-pkg-check-modules &&
make
#doxygen doc/doxygen.conf
make install
install -v -dm755 /usr/share/doc/libisoburn-1.5.4 &&
#install -v -m644 doc/html/* /usr/share/doc/libisoburn-1.5.4
popd
rm -rf libisoburn-1.5.4

#BLFS mkfs.fat command
rm -rf dosfstools-4.2
tar xf $BLFS_SRC_DIR/dosfstools-4.2.tar.gz
pushd dosfstools-4.2
./configure --prefix=/               \
            --enable-compat-symlinks \
            --mandir=/usr/share/man  \
            --docdir=/usr/share/doc/dosfstools-4.2 &&
make
make install
popd
rm -rf dosfstools-4.2

#BLFS cpio,Linux compile need cpio
rm -rf cpio-2.13
tar xf $BLFS_SRC_DIR/cpio-2.13.tar.bz2
pushd cpio-2.13
sed -i '/The name/,+2 d' src/global.c
./configure --prefix=/usr \
            --bindir=/bin \
            --enable-mt   \
            --with-rmt=/usr/libexec/rmt &&
make &&
makeinfo --html            -o doc/html      doc/cpio.texi &&
makeinfo --html --no-split -o doc/cpio.html doc/cpio.texi &&
makeinfo --plaintext       -o doc/cpio.txt  doc/cpio.texi
make -C doc pdf &&
make -C doc ps
make install &&
install -v -m755 -d /usr/share/doc/cpio-2.13/html &&
install -v -m644    doc/html/* \
                    /usr/share/doc/cpio-2.13/html &&
install -v -m644    doc/cpio.{html,txt} \
                    /usr/share/doc/cpio-2.13
#install -v -m644 doc/cpio.{pdf,ps,dvi} \
#                 /usr/share/doc/cpio-2.13
popd
rm -rf cpio-2.13

#BLFS iso command
rm -rf libuv-v1.41.0
tar xf $BLFS_SRC_DIR/libuv-v1.41.0.tar.gz
pushd libuv-v1.41.0
sh autogen.sh                              &&
./configure --prefix=/usr --disable-static &&
make
make install
popd
rm -rf libuv-v1.41.0



rm -rf libarchive-3.5.1
tar xf $BLFS_SRC_DIR/libarchive-3.5.1.tar.xz
pushd libarchive-3.5.1
./configure --prefix=/usr --disable-static &&
make
make install
popd
rm -rf libarchive-3.5.1

rm -rf wget-1.21.1
tar xf $BLFS_SRC_DIR/wget-1.21.1.tar.gz
pushd wget-1.21.1
./configure --prefix=/usr      \
            --sysconfdir=/etc  \
            --with-ssl=openssl &&
make
make install
popd
rm -rf wget-1.21.1

rm -rf libmnl-1.0.4
tar xf $BLFS_SRC_DIR/libmnl-1.0.4.tar.bz2
pushd libmnl-1.0.4
./configure --prefix=/usr &&
make
make install                 &&
mv /usr/lib/libmnl.so.* /lib &&
ln -sfv ../../lib/$(readlink /usr/lib/libmnl.so) /usr/lib/libmnl.so
popd
rm -rf libmnl-1.0.4

rm -rf ethtool-5.10
tar xf $BLFS_SRC_DIR/ethtool-5.10.tar.xz
pushd ethtool-5.10
./configure --prefix=/usr \
            --bindir=/bin &&
make
make install
popd
rm -rf ethtool-5.10

rm -rf cdrkit-release_1.1.11
tar xf $BLFS_SRC_DIR/cdrkit-release_1.1.11.tar.xz
pushd cdrkit-release_1.1.11
sed '1i CFLAGS += -fcommon' Makefile > Makefile-lfs-tmp
mv Makefile-lfs-tmp Makefile
make
make install PREFIX=/usr
ln -sfv  /usr/bin/genisoimage  /usr/bin/mkisofs
popd
rm -rf cdrkit-release_1.1.11

rm -rf squashfs4.4
tar xf $BLFS_SRC_DIR/squashfs4.4.tar.gz
pushd squashfs4.4/squashfs-tools
sed '1i CFLAGS += -fcommon' Makefile > Makefile-lfs-tmp
mv Makefile-lfs-tmp Makefile
make
make install INSTALL_DIR=/usr/bin
popd
rm -rf squashfs4.4

popd #LFS
