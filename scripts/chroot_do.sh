#!/bin/bash
#初始化日志文件并为其赋予适当的权限
touch /var/log/{btmp,lastlog,faillog,wtmp}
chgrp -v utmp /var/log/lastlog
chmod -v 664  /var/log/lastlog
chmod -v 600  /var/log/btmp


pushd /lfs


#7.7. Libstdc++ from GCC-10.2.0, Pass 2
pushd gcc-10.2.0
ln -s gthr-posix.h libgcc/gthr-default.h
rm build -rf
mkdir -v build
pushd build
../libstdc++-v3/configure            \
    CXXFLAGS="-g -O2 -D_GNU_SOURCE"  \
    --prefix=/usr                    \
    --disable-multilib               \
    --disable-nls                    \
    --host=$(uname -m)-lfs-linux-gnu \
    --disable-libstdcxx-pch

make
make install
popd #build
popd #gcc-10.2.0



#7.8. Gettext-0.21
pushd gettext-0.21
./configure --disable-shared
make
cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin
popd



#7.9. Bison-3.7.5
pushd bison-3.7.5
./configure --prefix=/usr \
            --docdir=/usr/share/doc/bison-3.7.5
make
make install
popd



#7.10. Perl-5.32.1
pushd perl-5.32.1
sh Configure -des                                        \
             -Dprefix=/usr                               \
             -Dvendorprefix=/usr                         \
             -Dprivlib=/usr/lib/perl5/5.32/core_perl     \
             -Darchlib=/usr/lib/perl5/5.32/core_perl     \
             -Dsitelib=/usr/lib/perl5/5.32/site_perl     \
             -Dsitearch=/usr/lib/perl5/5.32/site_perl    \
             -Dvendorlib=/usr/lib/perl5/5.32/vendor_perl \
             -Dvendorarch=/usr/lib/perl5/5.32/vendor_perl
make
make install
popd



#7.11. Python-3.9.2
pushd Python-3.9.2
./configure --prefix=/usr   \
            --enable-shared \
            --without-ensurepip

make 
make install
popd



#7.12. Texinfo-6.7
pushd texinfo-6.7
./configure --prefix=/usr
make 
make install
popd


#7.13. Util-linux-2.36.2
pushd util-linux-2.36.2
mkdir -pv /var/lib/hwclock
./configure ADJTIME_PATH=/var/lib/hwclock/adjtime    \
            --docdir=/usr/share/doc/util-linux-2.36.2 \
            --disable-chfn-chsh  \
            --disable-login      \
            --disable-nologin    \
            --disable-su         \
            --disable-setpriv    \
            --disable-runuser    \
            --disable-pylibmount \
            --disable-static     \
            --without-python     \
            runstatedir=/run
make 
make install
popd


popd #/lfs

#7.14. Cleaning up and Saving the Temporary System
#find /usr/{lib,libexec} -name \*.la -delete
#rm -rf /usr/share/{info,man,doc}/*

#退出chroot环境
#exit
#umount $LFS/dev{/pts,}
#umount $LFS/{sys,proc,run}

#strip --strip-debug $LFS/usr/lib/*
#strip --strip-unneeded $LFS/usr/{,s}bin/*
#strip --strip-unneeded $LFS/tools/bin/*

#7.14.3. Restore
#cd $LFS &&
#rm -rf ./* &&
#tar -xpf $HOME/lfs-temp-tools-10.1.tar.xz
