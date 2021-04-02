#!/bin/bash
set -e
cat > ~/.bash_profile << "EOF"
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
EOF

cat > ~/.bashrc << "EOF"
set +h
umask 022
LFS=/mnt/lfs
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
PATH=$LFS/tools/bin:$PATH
CONFIG_SITE=$LFS/usr/share/config.site
export LFS LC_ALL LFS_TGT PATH CONFIG_SITE
export LFS=/mnt/lfs
EOF

source ~/.bashrc

export MAKEFLAGS='-j4'

pushd $LFS/lfs


#Chapter 6. Cross Compiling Temporary Tools

#6.2. M4-1.4.18
pushd m4-1.4.18
sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' lib/*.c
echo "#define _IO_IN_BACKUP 0x100" >> lib/stdio-impl.h
./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)
make
make DESTDIR=$LFS install
popd



#6.3. Ncurses-6.2
rm ncurses-6.2 -rf
tar xvf $LFS/sources/ncurses-6.2.tar.gz
pushd ncurses-6.2
sed -i s/mawk// configure
rm build -rf
mkdir build
pushd build
  ../configure
popd #build
make -C build/include
make -C build/progs tic
./configure --prefix=/usr                \
            --host=$LFS_TGT              \
            --build=$(./config.guess)    \
            --mandir=/usr/share/man      \
            --with-manpage-format=normal \
            --with-shared                \
            --without-debug              \
            --without-ada                \
            --without-normal             \
            --enable-widec
make
make DESTDIR=$LFS TIC_PATH=$(pwd)/build/progs/tic install
echo "INPUT(-lncursesw)" > $LFS/usr/lib/libncurses.so
mv -v $LFS/usr/lib/libncursesw.so.6* $LFS/lib
ln -sfv ../../lib/$(readlink $LFS/usr/lib/libncursesw.so) $LFS/usr/lib/libncursesw.so
popd


#6.4. Bash-5.1
pushd bash-5.1
./configure --prefix=/usr                   \
            --build=$(support/config.guess) \
            --host=$LFS_TGT                 \
            --without-bash-malloc
make
make DESTDIR=$LFS install
mv $LFS/usr/bin/bash $LFS/bin/bash
ln -sfv bash $LFS/bin/sh
popd



#6.5. Coreutils-8.32
rm coreutils-8.32 -rf
tar xvf $LFS/sources/coreutils-8.32.tar.xz
pushd coreutils-8.32
patch -Np1 -i $LFS/sources/coreutils-8.32-i18n-1.patch
./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess) \
            --enable-install-program=hostname \
            --enable-no-install-program=kill,uptime
make
make DESTDIR=$LFS install
mv -v $LFS/usr/bin/{cat,chgrp,chmod,chown,cp,date,dd,df,echo} $LFS/bin
mv -v $LFS/usr/bin/{false,ln,ls,mkdir,mknod,mv,pwd,rm}        $LFS/bin
mv -v $LFS/usr/bin/{rmdir,stty,sync,true,uname}               $LFS/bin
mv -v $LFS/usr/bin/{head,nice,sleep,touch}                    $LFS/bin
mv -v $LFS/usr/bin/chroot                                     $LFS/usr/sbin
mkdir -pv $LFS/usr/share/man/man8
mv -v $LFS/usr/share/man/man1/chroot.1                        $LFS/usr/share/man/man8/chroot.8
sed -i 's/"1"/"8"/'                                           $LFS/usr/share/man/man8/chroot.8
popd


#6.6. Diffutils-3.7
pushd diffutils-3.7
./configure --prefix=/usr --host=$LFS_TGT
make
make DESTDIR=$LFS install
popd


#6.7. File-5.39
rm file-5.39 -rf
tar xvf $LFS/sources/file-5.39.tar.gz
pushd file-5.39
rm build -rf
mkdir build
pushd build
  ../configure --disable-bzlib      \
               --disable-libseccomp \
               --disable-xzlib      \
               --disable-zlib
  make
popd #build
./configure --prefix=/usr --host=$LFS_TGT --build=$(./config.guess)
make FILE_COMPILE=$(pwd)/build/src/file
make DESTDIR=$LFS install
popd


#6.8. Findutils-4.8.0
pushd findutils-4.8.0
./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)
make
make DESTDIR=$LFS install
mv -v $LFS/usr/bin/find $LFS/bin
sed -i 's|find:=${BINDIR}|find:=/bin|' $LFS/usr/bin/updatedb
popd


#6.9. Gawk-5.1.0
pushd gawk-5.1.0
sed -i 's/extras//' Makefile.in
./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(./config.guess)
make
make DESTDIR=$LFS install
popd



#6.10. Grep-3.6
pushd grep-3.6
./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --bindir=/bin
make
make DESTDIR=$LFS install
popd



#6.11. Gzip-1.10
pushd gzip-1.10
./configure --prefix=/usr --host=$LFS_TGT
make
make DESTDIR=$LFS install
#Move the executable to its final expected location:
mv -v $LFS/usr/bin/gzip $LFS/bin
popd



#6.12. Make-4.3
pushd make-4.3
./configure --prefix=/usr   \
            --without-guile \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)
make
make DESTDIR=$LFS install
popd



#6.13. Patch-2.7.6
rm patch-2.7.6 -rf
tar xvf $LFS/sources/patch-2.7.6.tar.xz
pushd patch-2.7.6
patch -Np1 -i $LFS/sources/patch-2.7.6-util.patch
./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)
make
make DESTDIR=$LFS install
popd



#6.14. Sed-4.8
pushd sed-4.8
./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --bindir=/bin
make
make DESTDIR=$LFS install
popd



#6.15. Tar-1.34
pushd tar-1.34
./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess) \
            --bindir=/bin
make
make DESTDIR=$LFS install
popd



#6.16. Xz-5.2.5
pushd xz-5.2.5
./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess) \
            --disable-static                  \
            --docdir=/usr/share/doc/xz-5.2.5
make
make DESTDIR=$LFS install
#Make sure that all essential files are in the correct directory:
mv -v $LFS/usr/bin/{lzma,unlzma,lzcat,xz,unxz,xzcat}  $LFS/bin
mv -v $LFS/usr/lib/liblzma.so.*                       $LFS/lib
ln -svf ../../lib/$(readlink $LFS/usr/lib/liblzma.so) $LFS/usr/lib/liblzma.so
popd



#6.17. Binutils-2.36.1 - Pass 2
pushd binutils-2.36.1
rm build -rf
mkdir -v build
pushd build
../configure                   \
    --prefix=/usr              \
    --build=$(../config.guess) \
    --host=$LFS_TGT            \
    --disable-nls              \
    --enable-shared            \
    --disable-werror           \
    --enable-64-bit-bfd

make
make DESTDIR=$LFS install
install -vm755 libctf/.libs/libctf.so.0.0.0 $LFS/usr/lib
popd #build
popd #binutils-2.36.1



#6.18. GCC-10.2.0 - Pass 2
pushd gcc-10.2.0
rm mpfr gmp mpc -rf
tar -xf $LFS/sources/mpfr-4.1.0.tar.xz
mv -v mpfr-4.1.0 mpfr
tar -xf $LFS/sources/gmp-6.2.1.tar.xz
mv -v gmp-6.2.1 gmp
tar -xf $LFS/sources/mpc-1.2.1.tar.gz
mv -v mpc-1.2.1 mpc

case $(uname -m) in
  x86_64)
    sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64
  ;;
esac

rm build -rf
mkdir -v build
pushd build
#Create a symlink that allows libgcc to be built with posix threads support:
mkdir -pv $LFS_TGT/libgcc
ln -svf ../../../libgcc/gthr-posix.h $LFS_TGT/libgcc/gthr-default.h
../configure                                       \
    --build=$(../config.guess)                     \
    --host=$LFS_TGT                                \
    --prefix=/usr                                  \
    CC_FOR_TARGET=$LFS_TGT-gcc                     \
    --with-build-sysroot=$LFS                      \
    --enable-initfini-array                        \
    --disable-nls                                  \
    --disable-multilib                             \
    --disable-decimal-float                        \
    --disable-libatomic                            \
    --disable-libgomp                              \
    --disable-libquadmath                          \
    --disable-libssp                               \
    --disable-libvtv                               \
    --disable-libstdcxx                            \
    --enable-languages=c,c++

make
make DESTDIR=$LFS install
ln -svf gcc $LFS/usr/bin/cc
popd #build
popd #gcc-10.2.0


popd #$LFS/lfs
