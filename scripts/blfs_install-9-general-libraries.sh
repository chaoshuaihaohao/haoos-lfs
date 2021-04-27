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

rm -rf apr-1.7.0
tar xf $BLFS_SRC_DIR/apr-1.7.0.tar.bz2
pushd apr-1.7.0
./configure --prefix=/usr    \
            --disable-static \
            --with-installbuilddir=/usr/share/apr-1/build &&
make
make install
rm -rf apr-1.7.0

rm -rf apr-util-1.6.1
tar xf $BLFS_SRC_DIR/apr-util-1.6.1.tar.bz2
pushd apr-util-1.6.1
./configure --prefix=/usr       \
            --with-apr=/usr     \
            --with-gdbm=/usr    \
            --with-openssl=/usr \
            --with-crypto &&
make
make install
popd
rm -rf apr-util-1.6.1

:<<eof
rm -rf aspell-0.60.8
tar xf $BLFS_SRC_DIR/aspell-0.60.8.tar.gz
pushd aspell-0.60.8
./configure --prefix=/usr &&
make
make install &&
ln -svfn aspell-0.60 /usr/lib/aspell &&

install -v -m755 -d /usr/share/doc/aspell-0.60.8/aspell{,-dev}.html &&

install -v -m644 manual/aspell.html/* \
    /usr/share/doc/aspell-0.60.8/aspell.html &&

install -v -m644 manual/aspell-dev.html/* \
    /usr/share/doc/aspell-0.60.8/aspell-dev.html
install -v -m 755 scripts/ispell /usr/bin/
install -v -m 755 scripts/spell /usr/bin/
eof

rm -rf libusb-1.0.24
tar xf $BLFS_SRC_DIR/libusb-1.0.24.tar.bz2
pushd libusb-1.0.24
./configure --prefix=/usr --disable-static &&
make
#sed -i "s/^TCL_SUBST/#&/; s/wide//" doc/doxygen.cfg &&
#make -C doc docs
make install
install -v -d -m755 /usr/share/doc/libusb-1.0.24/apidocs &&
#install -v -m644    doc/html/* \
#                    /usr/share/doc/libusb-1.0.24/apidocs
popd
rm -rf 

:<<eof
rm -rf 
tar xf $BLFS_SRC_DIR/
pushd 

popd
rm -rf 

rm -rf 
tar xf $BLFS_SRC_DIR/
pushd 

popd
rm -rf 

rm -rf 
tar xf $BLFS_SRC_DIR/
pushd 

popd
rm -rf 

rm -rf 
tar xf $BLFS_SRC_DIR/
pushd 

popd
rm -rf 

rm -rf 
tar xf $BLFS_SRC_DIR/
pushd 

popd
rm -rf 
eof


popd #LFS
