#!/bin/sh
set -e
#
export MAKEFLAGS='-j4'
pushd /lfs

#BLFS cpio,Linux compile need cpio
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

#BLFS iso command
pushd libuv-v1.41.0
sh autogen.sh                              &&
./configure --prefix=/usr --disable-static &&
make
make install
popd

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

pushd libarchive-3.5.1
./configure --prefix=/usr --disable-static &&
make
make install
popd

pushd wget-1.21.1
./configure --prefix=/usr      \
            --sysconfdir=/etc  \
            --with-ssl=openssl &&
make
make install
popd

pushd libmnl-1.0.4
./configure --prefix=/usr &&
make
make install                 &&
mv /usr/lib/libmnl.so.* /lib &&
ln -sfv ../../lib/$(readlink /usr/lib/libmnl.so) /usr/lib/libmnl.so
popd

pushd ethtool-5.10
./configure --prefix=/usr \
            --bindir=/bin &&
make
make install
popd

pushd cdrkit-release_1.1.11
make
make install PREFIX=/usr
ln -sfv  /usr/bin/genisoimage  /usr/bin/mkisofs
popd

pushd squashfs4.4/squashfs-tools
make
make install INSTALL_DIR=/usr/bin
popd

popd #LFS
