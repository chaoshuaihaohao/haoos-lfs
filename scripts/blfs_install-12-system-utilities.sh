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

rm -rf pciutils-3.7.0
tar xf $BLFS_SRC_DIR/pciutils-3.7.0.tar.xz
pushd pciutils-3.7.0

make PREFIX=/usr                \
     SHAREDIR=/usr/share/hwdata \
     SHARED=yes

make PREFIX=/usr                \
     SHAREDIR=/usr/share/hwdata \
     SHARED=yes                 \
     install install-lib        &&

chmod -v 755 /usr/lib/libpci.so
#update-pciids

cat > /lib/systemd/system/update-pciids.service << "EOF" &&
[Unit]
Description=Update pci.ids file
Documentation=man:update-pciids(8)
DefaultDependencies=no
After=local-fs.target network-online.target
Before=shutdown.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/sbin/update-pciids
EOF
cat > /lib/systemd/system/update-pciids.timer << "EOF" &&
[Unit]
Description=Update pci.ids file weekly

[Timer]
OnCalendar=Sun 02:30:00
Persistent=true

[Install]
WantedBy=timers.target
EOF
systemctl enable update-pciids.timer

rm -rf unzip60
tar xf $BLFS_SRC_DIR/unzip60.tar.gz
pushd unzip60
make -f unix/Makefile generic
make prefix=/usr MANDIR=/usr/share/man/man1 \
 -f unix/Makefile install
popd
rm -rf unzip60

rm -rf usbutils-013
tar xf $BLFS_SRC_DIR/usbutils-013.tar.xz
pushd usbutils-013
./autogen.sh --prefix=/usr --datadir=/usr/share/hwdata &&
make
make install
install -dm755 /usr/share/hwdata/ &&
wget http://www.linux-usb.org/usb.ids -O /usr/share/hwdata/usb.ids
popd
rm -rf usbutils-013

:<<eof
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
popd #LFS
eof
