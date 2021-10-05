#!/bin/bash
set -e
#7.6-2. 创建必要的文件和符号链接
touch /var/log/{btmp,lastlog,faillog,wtmp}
chgrp -v utmp /var/log/lastlog
chmod -v 664  /var/log/lastlog
chmod -v 600  /var/log/btmp

if [ -n $JOBS ];then
        JOBS=`grep -c ^processor /proc/cpuinfo 2>/dev/null`
        if [ ! $JOBS ];then
                JOBS="1"
        fi
fi
export MAKEFLAGS=-j$JOBS

#7.7. GCC-10.2.0 中的 Libstdc++，第二遍
#7.8. Gettext-0.21
#7.9. Bison-3.7.5
#7.10. Perl-5.32.1
#7.11. Python-3.9.2
#7.12. Texinfo-6.7
#7.13. Util-linux-2.36.2
./os-build/install.sh -f ./os-build/lfs-list-chapter07

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
