#!/bin/bash
set -e
#Part IV. Building the LFS System
#Chapter 8. Installing Basic System Software

#8.76. 再次移除调试符号
save_lib="ld-2.33.so libc-2.33.so libpthread-2.33.so libthread_db-1.0.so"

pushd /lib

for LIB in $save_lib; do
    objcopy --only-keep-debug $LIB $LIB.dbg 
    strip --strip-unneeded $LIB
    objcopy --add-gnu-debuglink=$LIB.dbg $LIB 
done 

save_usrlib="libquadmath.so.0.0.0 libstdc++.so.6.0.28
             libitm.so.1.0.0 libatomic.so.1.2.0" 
popd #/lib

pushd /usr/lib

for LIB in $save_usrlib; do
    objcopy --only-keep-debug $LIB $LIB.dbg
    strip --strip-unneeded $LIB
    objcopy --add-gnu-debuglink=$LIB.dbg $LIB
done

unset LIB save_lib save_usrlib
popd #/usr/lib


find /usr/lib -type f -name \*.a \
   -exec strip --strip-debug {} ';'

find /lib /usr/lib -type f -name \*.so* ! -name \*dbg \
   -exec strip --strip-unneeded {} ';'

find /{bin,sbin} /usr/{bin,sbin,libexec} -type f \
    -exec strip --strip-all {} ';'

#8.77. 清理系统
rm -rf /tmp/*
echo finished. Please 'logout' to virt host console and 'make chroot-again'
