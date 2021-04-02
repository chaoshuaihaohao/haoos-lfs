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


#Chapter 5. Compiling a Cross-Toolchain
###安装编译工具gcc\ld等
##交叉编译工具安装到$LFS/tools目录下
#5.2. Binutils-2.36.1 - Pass 1
pushd binutils-2.36.1
rm build -rf
mkdir -v build
pushd build

../configure --prefix=$LFS/tools       \
             --with-sysroot=$LFS        \
             --target=$LFS_TGT          \
             --disable-nls              \
             --disable-werror
make
make install
popd #build
popd #binutils-2.36.1

#5.3. GCC-10.2.0 - Pass 1
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
    sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64
 ;;
esac

rm build -rf
mkdir -v build
pushd build

../configure                                       \
    --target=$LFS_TGT                              \
    --prefix=$LFS/tools                            \
    --with-glibc-version=2.11                      \
    --with-sysroot=$LFS                            \
    --with-newlib                                  \
    --without-headers                              \
    --enable-initfini-array                        \
    --disable-nls                                  \
    --disable-shared                               \
    --disable-multilib                             \
    --disable-decimal-float                        \
    --disable-threads                              \
    --disable-libatomic                            \
    --disable-libgomp                              \
    --disable-libquadmath                          \
    --disable-libssp                               \
    --disable-libvtv                               \
    --disable-libstdcxx                            \
    --enable-languages=c,c++
make
make install
pushd ..
cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
  `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/install-tools/include/limits.h
popd #..
popd #build
popd #gcc


#5.4. Linux-5.10.17 API Headers
pushd linux-5.10.17
make mrproper
make headers
find usr/include -name '.*' -delete
rm usr/include/Makefile
cp -rv usr/include $LFS/usr
popd



#5.5. Glibc-2.33
pushd glibc-2.33
case $(uname -m) in
    i?86)   ln -sfv ld-linux.so.2 $LFS/lib/ld-lsb.so.3
    ;;
    x86_64) ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64
            ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3
    ;;
esac
patch -Np1 -i $LFS/sources/glibc-2.33-fhs-1.patch
rm build -rf
mkdir -v build
pushd build

../configure                             \
      --prefix=/usr                      \
      --host=$LFS_TGT                    \
      --build=$(../scripts/config.guess) \
      --enable-kernel=3.2                \
      --with-headers=$LFS/usr/include    \
      libc_cv_slibdir=/lib
make
make DESTDIR=$LFS install

#检查glic
echo 'int main(){}' > dummy.c
$LFS_TGT-gcc dummy.c
readelf -l a.out | grep '/ld-linux'

rm -v dummy.c a.out

$LFS/tools/libexec/gcc/$LFS_TGT/10.2.0/install-tools/mkheaders
popd #build
popd #glibc



#5.6. Libstdc++ from GCC-10.2.0, Pass 1
pushd gcc-10.2.0
rm build -rf
mkdir -v build
pushd build

../libstdc++-v3/configure           \
    --host=$LFS_TGT                 \
    --build=$(../config.guess)      \
    --prefix=/usr                   \
    --disable-multilib              \
    --disable-nls                   \
    --disable-libstdcxx-pch         \
    --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/10.2.0
make
make DESTDIR=$LFS install
popd #build
popd #gcc



popd #$LFS/lfs
