#!/bin/sh
set -e
#
if [ `id -u` != 0 ];then
        echo Permission delay, Please run as root!
        exit
fi

export MAKEFLAGS='-j4'
export SOURCES=/blfs-sources
pushd /lfs

rm -rf libburn-1.5.4
tar xf $SOURCES/libburn-1.5.4.tar.gz
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
tar xf $SOURCES/libisofs-1.5.4.tar.gz
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
tar xf $SOURCES/libisoburn-1.5.4.tar.gz
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
tar xf $SOURCES/dosfstools-4.2.tar.gz
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
tar xf $SOURCES/cpio-2.13.tar.bz2
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
tar xf $SOURCES/libuv-v1.41.0.tar.gz
pushd libuv-v1.41.0
sh autogen.sh                              &&
./configure --prefix=/usr --disable-static &&
make
make install
popd
rm -rf libuv-v1.41.0

rm -rf curl-7.75.0
tar xf $SOURCES/curl-7.75.0.tar.xz
pushd curl-7.75.0
grep -rl '#!.*python$' | xargs sed -i '1s/python/&3/'
./configure --prefix=/usr                           \
            --disable-static                        \
            --enable-threaded-resolver              \
            --with-ca-path=/etc/ssl/certs &&
make
make install &&
rm -rf docs/examples/.deps &&
find docs \( -name Makefile\* -o -name \*.1 -o -name \*.3 \) -exec rm {} \; &&
install -v -d -m755 /usr/share/doc/curl-7.75.0 &&
cp -v -R docs/*     /usr/share/doc/curl-7.75.0
popd
rm -rf curl-7.75.0

rm -rf libarchive-3.5.1
tar xf $SOURCES/libarchive-3.5.1.tar.xz
pushd libarchive-3.5.1
./configure --prefix=/usr --disable-static &&
make
make install
popd
rm -rf libarchive-3.5.1

rm -rf cmake-3.19.5
tar xf $SOURCES/cmake-3.19.5.tar.gz
pushd cmake-3.19.5
sed -i '/"lib64"/s/64//' Modules/GNUInstallDirs.cmake &&
./bootstrap --prefix=/usr        \
            --system-libs        \
            --mandir=/share/man  \
            --no-system-jsoncpp  \
            --no-system-librhash \
            --docdir=/share/doc/cmake-3.19.5 &&
make
make install
popd
rm -rf cmake-3.19.5

rm -rf wget-1.21.1
tar xf $SOURCES/wget-1.21.1.tar.gz
pushd wget-1.21.1
./configure --prefix=/usr      \
            --sysconfdir=/etc  \
            --with-ssl=openssl &&
make
make install
popd
rm -rf wget-1.21.1

rm -rf libmnl-1.0.4
tar xf $SOURCES/libmnl-1.0.4.tar.bz2
pushd libmnl-1.0.4
./configure --prefix=/usr &&
make
make install                 &&
mv /usr/lib/libmnl.so.* /lib &&
ln -sfv ../../lib/$(readlink /usr/lib/libmnl.so) /usr/lib/libmnl.so
popd
rm -rf libmnl-1.0.4

rm -rf ethtool-5.10
tar xf $SOURCES/ethtool-5.10.tar.xz
pushd ethtool-5.10
./configure --prefix=/usr \
            --bindir=/bin &&
make
make install
popd
rm -rf ethtool-5.10

rm -rf cdrkit-release_1.1.11
tar xf $SOURCES/cdrkit-release_1.1.11.tar.xz
pushd cdrkit-release_1.1.11
sed '1i CFLAGS += -fcommon' Makefile > Makefile-lfs-tmp
mv Makefile-lfs-tmp Makefile
make
make install PREFIX=/usr
ln -sfv  /usr/bin/genisoimage  /usr/bin/mkisofs
popd
rm -rf cdrkit-release_1.1.11

rm -rf squashfs4.4
tar xf $SOURCES/squashfs4.4.tar.gz
pushd squashfs4.4/squashfs-tools
sed '1i CFLAGS += -fcommon' Makefile > Makefile-lfs-tmp
mv Makefile-lfs-tmp Makefile
make
make install INSTALL_DIR=/usr/bin
popd
rm -rf squashfs4.4

popd #LFS
