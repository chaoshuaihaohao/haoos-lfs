#!/bin/bash
set -e
#Part IV. Building the LFS System
#Chapter 8. Installing Basic System Software

export MAKEFLAGS='-j4'
pushd /lfs

#8.3. Man-pages-5.10
pushd man-pages-5.10
make install
popd

#8.4. Iana-Etc-20210202
pushd iana-etc-20210202
cp services protocols /etc
popd

#8.5. Glibc-2.33
#8.5.1. Installation of Glibc
rm glibc-2.33 -rf
tar xvf /sources/glibc-2.33.tar.xz
pushd glibc-2.33
patch -Np1 -i /sources/glibc-2.33-fhs-1.patch
sed -e '402a\      *result = local->data.services[database_index];' \
    -i nss/nss_database.c
rm build -rf
mkdir -v build
pushd build
../configure --prefix=/usr                            \
             --disable-werror                         \
             --enable-kernel=3.2                      \
             --enable-stack-protector=strong          \
             --with-headers=/usr/include              \
             libc_cv_slibdir=/lib
make
#make check
touch /etc/ld.so.conf
sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile
make install
cp -v ../nscd/nscd.conf /etc/nscd.conf
mkdir -pv /var/cache/nscd
mkdir -pv /usr/lib/locale
localedef -i POSIX -f UTF-8 C.UTF-8 2> /dev/null || true
localedef -i cs_CZ -f UTF-8 cs_CZ.UTF-8
localedef -i de_DE -f ISO-8859-1 de_DE
localedef -i de_DE@euro -f ISO-8859-15 de_DE@euro
localedef -i de_DE -f UTF-8 de_DE.UTF-8
localedef -i el_GR -f ISO-8859-7 el_GR
localedef -i en_GB -f UTF-8 en_GB.UTF-8
localedef -i en_HK -f ISO-8859-1 en_HK
localedef -i en_PH -f ISO-8859-1 en_PH
localedef -i en_US -f ISO-8859-1 en_US
localedef -i en_US -f UTF-8 en_US.UTF-8
localedef -i es_MX -f ISO-8859-1 es_MX
localedef -i fa_IR -f UTF-8 fa_IR
localedef -i fr_FR -f ISO-8859-1 fr_FR
localedef -i fr_FR@euro -f ISO-8859-15 fr_FR@euro
localedef -i fr_FR -f UTF-8 fr_FR.UTF-8
localedef -i it_IT -f ISO-8859-1 it_IT
localedef -i it_IT -f UTF-8 it_IT.UTF-8
localedef -i ja_JP -f EUC-JP ja_JP
localedef -i ja_JP -f SHIFT_JIS ja_JP.SIJS 2> /dev/null || true
localedef -i ja_JP -f UTF-8 ja_JP.UTF-8
localedef -i ru_RU -f KOI8-R ru_RU.KOI8-R
localedef -i ru_RU -f UTF-8 ru_RU.UTF-8
localedef -i tr_TR -f UTF-8 tr_TR.UTF-8
localedef -i zh_CN -f GB18030 zh_CN.GB18030
localedef -i zh_HK -f BIG5-HKSCS zh_HK.BIG5-HKSCS
make localedata/install-locales

#8.5.2. Configuring Glibc
#8.5.2.1. Adding nsswitch.conf
cat > /etc/nsswitch.conf << "EOF"
# Begin /etc/nsswitch.conf

passwd: files
group: files
shadow: files

hosts: files dns
networks: files

protocols: files
services: files
ethers: files
rpc: files

# End /etc/nsswitch.conf
EOF

#8.5.2.2. Adding time zone data
tar -xf /sources/tzdata2021a.tar.gz

ZONEINFO=/usr/share/zoneinfo
mkdir -pv $ZONEINFO/{posix,right}

for tz in etcetera southamerica northamerica europe africa antarctica  \
          asia australasia backward; do
    zic -L /dev/null   -d $ZONEINFO       ${tz}
    zic -L /dev/null   -d $ZONEINFO/posix ${tz}
    zic -L leapseconds -d $ZONEINFO/right ${tz}
done

cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
zic -d $ZONEINFO -p America/New_York
unset ZONEINFO

#read $zone
ln -sfv /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

#8.5.2.3. Configuring the Dynamic Loader
cat > /etc/ld.so.conf << "EOF"
# Begin /etc/ld.so.conf
/usr/local/lib
/opt/lib

EOF

cat >> /etc/ld.so.conf << "EOF"
# Add an include directory
include /etc/ld.so.conf.d/*.conf

EOF
mkdir -pv /etc/ld.so.conf.d

popd #build
popd

#8.6. Zlib-1.2.11
pushd zlib-1.2.11
./configure --prefix=/usr
make
#make check
make install
mv -v /usr/lib/libz.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libz.so) /usr/lib/libz.so
rm -fv /usr/lib/libz.a
popd

#8.7. Bzip2-1.0.8
rm bzip2-1.0.8 -rf
tar xvf /sources/bzip2-1.0.8.tar.gz
pushd bzip2-1.0.8
patch -Np1 -i /sources/bzip2-1.0.8-install_docs-1.patch
sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile
sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile
make -f Makefile-libbz2_so
make clean
make
make PREFIX=/usr install
cp -v bzip2-shared /bin/bzip2
cp -av libbz2.so* /lib
ln -sfv ../../lib/libbz2.so.1.0 /usr/lib/libbz2.so
rm -v /usr/bin/{bunzip2,bzcat,bzip2}
ln -sfv bzip2 /bin/bunzip2
ln -sfv bzip2 /bin/bzcat
rm -fv /usr/lib/libbz2.a
popd



#8.8. Xz-5.2.5
pushd xz-5.2.5
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/xz-5.2.5
make
#make check
make install
mv -v   /usr/bin/{lzma,unlzma,lzcat,xz,unxz,xzcat} /bin
mv -v /usr/lib/liblzma.so.* /lib
ln -svf ../../lib/$(readlink /usr/lib/liblzma.so) /usr/lib/liblzma.so
popd

#8.9. Zstd-1.4.8
pushd zstd-1.4.8
make
#make check
make prefix=/usr install
rm -v /usr/lib/libzstd.a
mv -v /usr/lib/libzstd.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libzstd.so) /usr/lib/libzstd.so
popd


#8.10. File-5.39
rm file-5.39 -rf
tar xvf /sources/file-5.39.tar.gz
pushd file-5.39
./configure --prefix=/usr
make
#make check
make install
popd



#8.11. Readline-8.1
pushd readline-8.1
sed -i '/MV.*old/d' Makefile.in
sed -i '/{OLDSUFF}/c:' support/shlib-install
./configure --prefix=/usr    \
            --disable-static \
            --with-curses    \
            --docdir=/usr/share/doc/readline-8.1
make SHLIB_LIBS="-lncursesw"
make SHLIB_LIBS="-lncursesw" install
mv -v /usr/lib/lib{readline,history}.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libreadline.so) /usr/lib/libreadline.so
ln -sfv ../../lib/$(readlink /usr/lib/libhistory.so ) /usr/lib/libhistory.so
install -v -m644 doc/*.{ps,pdf,html,dvi} /usr/share/doc/readline-8.1
popd

#8.12. M4-1.4.18
rm m4-1.4.18 -rf
tar xvf /sources/m4-1.4.18.tar.xz
pushd m4-1.4.18
sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' lib/*.c
if [ ! "`grep -rn "#define _IO_IN_BACKUP 0x100" lib/stdio-impl.h | head -1`" ];then
	echo "#define _IO_IN_BACKUP 0x100" >> lib/stdio-impl.h
fi
./configure --prefix=/usr
make
#make check
make install
popd

#8.13. Bc-3.3.0
pushd bc-3.3.0
PREFIX=/usr CC=gcc ./configure.sh -G -O3
make
make test
make install
popd



#8.14. Flex-2.6.4
pushd flex-2.6.4
./configure --prefix=/usr \
            --docdir=/usr/share/doc/flex-2.6.4 \
            --disable-static
make
make check
make install
ln -svf flex /usr/bin/lex
popd



#8.15. Tcl-8.6.11
pushd tcl8.6.11
tar -xf /sources/tcl8.6.11-html.tar.gz --strip-components=1
SRCDIR=$(pwd)
cd unix
./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            $([ "$(uname -m)" = x86_64 ] && echo --enable-64bit)
make

sed -e "s|$SRCDIR/unix|/usr/lib|" \
    -e "s|$SRCDIR|/usr/include|"  \
    -i tclConfig.sh

sed -e "s|$SRCDIR/unix/pkgs/tdbc1.1.2|/usr/lib/tdbc1.1.2|" \
    -e "s|$SRCDIR/pkgs/tdbc1.1.2/generic|/usr/include|"    \
    -e "s|$SRCDIR/pkgs/tdbc1.1.2/library|/usr/lib/tcl8.6|" \
    -e "s|$SRCDIR/pkgs/tdbc1.1.2|/usr/include|"            \
    -i pkgs/tdbc1.1.2/tdbcConfig.sh

sed -e "s|$SRCDIR/unix/pkgs/itcl4.2.1|/usr/lib/itcl4.2.1|" \
    -e "s|$SRCDIR/pkgs/itcl4.2.1/generic|/usr/include|"    \
    -e "s|$SRCDIR/pkgs/itcl4.2.1|/usr/include|"            \
    -i pkgs/itcl4.2.1/itclConfig.sh

unset SRCDIR
#make test
make install
chmod -v u+w /usr/lib/libtcl8.6.so
make install-private-headers
ln -sfv tclsh8.6 /usr/bin/tclsh
mv /usr/share/man/man3/{Thread,Tcl_Thread}.3
popd



#8.16. Expect-5.45.4
pushd expect5.45.4
./configure --prefix=/usr           \
            --with-tcl=/usr/lib     \
            --enable-shared         \
            --mandir=/usr/share/man \
            --with-tclinclude=/usr/include
make
#make test
make install
ln -svf expect5.45.4/libexpect5.45.4.so /usr/lib
popd



#8.17. DejaGNU-1.6.2
pushd dejagnu-1.6.2
./configure --prefix=/usr
makeinfo --html --no-split -o doc/dejagnu.html doc/dejagnu.texi
makeinfo --plaintext       -o doc/dejagnu.txt  doc/dejagnu.texi
make install
install -v -dm755  /usr/share/doc/dejagnu-1.6.2
install -v -m644   doc/dejagnu.{html,txt} /usr/share/doc/dejagnu-1.6.2
#make check
popd



#8.18. Binutils-2.36.1
pushd binutils-2.36.1
if [ `expect -c "spawn ls"` == "spawn ls" ];then
	echo spawn ls output error
	exit
fi
sed -i '/@\tincremental_copy/d' gold/testsuite/Makefile.in
rm build -rf
mkdir -v build
pushd build
../configure --prefix=/usr       \
             --enable-gold       \
             --enable-ld=default \
             --enable-plugins    \
             --enable-shared     \
             --disable-werror    \
             --enable-64-bit-bfd \
             --with-system-zlib
make tooldir=/usr
#make -k check
make tooldir=/usr install
rm -fv /usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes}.a
popd #build
popd



#8.19. GMP-6.2.1
pushd gmp-6.2.1
./configure --prefix=/usr    \
            --enable-cxx     \
            --disable-static \
            --docdir=/usr/share/doc/gmp-6.2.1
make
make html
#make check 2>&1 | tee gmp-check-log
#awk '/# PASS:/{total+=$3} ; END{print total}' gmp-check-log
make install
make install-html
popd



#8.20. MPFR-4.1.0
pushd mpfr-4.1.0
./configure --prefix=/usr        \
            --disable-static     \
            --enable-thread-safe \
            --docdir=/usr/share/doc/mpfr-4.1.0
make
make html
#make check
make install
make install-html
popd



#8.21. MPC-1.2.1
pushd mpc-1.2.1
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/mpc-1.2.1
make
make html
#make check
make install
make install-html
popd



#8.22. Attr-2.4.48
pushd attr-2.4.48
./configure --prefix=/usr     \
            --bindir=/bin     \
            --disable-static  \
            --sysconfdir=/etc \
            --docdir=/usr/share/doc/attr-2.4.48
make
#make check
make install
mv -v /usr/lib/libattr.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libattr.so) /usr/lib/libattr.so
popd



#8.23. Acl-2.2.53
pushd acl-2.2.53
./configure --prefix=/usr         \
            --bindir=/bin         \
            --disable-static      \
            --libexecdir=/usr/lib \
            --docdir=/usr/share/doc/acl-2.2.53
make
make install
mv -v /usr/lib/libacl.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libacl.so) /usr/lib/libacl.so
popd



#8.24. Libcap-2.48
pushd libcap-2.48
sed -i '/install -m.*STA/d' libcap/Makefile
make prefix=/usr lib=lib
#make test
make prefix=/usr lib=lib install
for libname in cap psx; do
    mv -v /usr/lib/lib${libname}.so.* /lib
    ln -sfv ../../lib/lib${libname}.so.2 /usr/lib/lib${libname}.so
    chmod -v 755 /lib/lib${libname}.so.2.48
done
popd



#8.25. Shadow-4.8.1
pushd shadow-4.8.1
sed -i 's/groups$(EXEEXT) //' src/Makefile.in
find man -name Makefile.in -exec sed -i 's/groups\.1 / /'   {} \;
find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
find man -name Makefile.in -exec sed -i 's/passwd\.5 / /'   {} \;
sed -e 's:#ENCRYPT_METHOD DES:ENCRYPT_METHOD SHA512:' \
    -e 's:/var/spool/mail:/var/mail:'                 \
    -i etc/login.defs
#If you chose to build Shadow with Cracklib support, run the following:
#sed -i 's:DICTPATH.*:DICTPATH\t/lib/cracklib/pw_dict:' etc/login.defs
sed -i 's/1000/999/' etc/useradd
touch /usr/bin/passwd
./configure --sysconfdir=/etc \
            --with-group-name-max-length=32
make
make install
#8.25.2. Configuring Shadow
#To enable shadowed passwords, run the following command:
pwconv
#To enable shadowed group passwords, run:
grpconv
#passwd root
popd



#8.26. GCC-10.2.0
rm gcc-10.2.0 -rf
tar xvf /sources/gcc-10.2.0.tar.xz
pushd gcc-10.2.0
case $(uname -m) in
  x86_64)
    sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64
  ;;
esac
rm build -rf
mkdir -v build
pushd       build
../configure --prefix=/usr            \
             LD=ld                    \
             --enable-languages=c,c++ \
             --disable-multilib       \
             --disable-bootstrap      \
             --with-system-zlib
make
ulimit -s 32768
#chown -Rv tester .
#su tester -c "PATH=$PATH make -k check"
#../contrib/test_summary
make install
rm -rf /usr/lib/gcc/$(gcc -dumpmachine)/10.2.0/include-fixed/bits/
chown -v -R root:root \
    /usr/lib/gcc/*linux-gnu/10.2.0/include{,-fixed}
ln -sfv ../usr/bin/cpp /lib
ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/10.2.0/liblto_plugin.so \
        /usr/lib/bfd-plugins/
#sanity checks
#echo 'int main(){}' > dummy.c
#cc dummy.c -v -Wl,--verbose &> dummy.log
#readelf -l a.out | grep ': /lib'
#grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log
#grep -B4 '^ /usr/include' dummy.log
#grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g'
#grep "/lib.*/libc.so.6 " dummy.log
#grep found dummy.log
#rm -v dummy.c a.out dummy.log
mkdir -pv /usr/share/gdb/auto-load/usr/lib
mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib
popd #build
popd



#8.27. Pkg-config-0.29.2
pushd pkg-config-0.29.2
./configure --prefix=/usr              \
            --with-internal-glib       \
            --disable-host-tool        \
            --docdir=/usr/share/doc/pkg-config-0.29.2
make
#make check
make install
popd



#8.28. Ncurses-6.2
rm ncurses-6.2 -rf
tar xvf /sources/ncurses-6.2.tar.gz
pushd ncurses-6.2
./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            --with-shared           \
            --without-debug         \
            --without-normal        \
            --enable-pc-files       \
            --enable-widec
make
make install
mv -v /usr/lib/libncursesw.so.6* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libncursesw.so) /usr/lib/libncursesw.so
for lib in ncurses form panel menu ; do
    rm -vf                    /usr/lib/lib${lib}.so
    echo "INPUT(-l${lib}w)" > /usr/lib/lib${lib}.so
    ln -sfv ${lib}w.pc        /usr/lib/pkgconfig/${lib}.pc
done
rm -vf                     /usr/lib/libcursesw.so
echo "INPUT(-lncursesw)" > /usr/lib/libcursesw.so
ln -sfv libncurses.so      /usr/lib/libcurses.so
rm -fv /usr/lib/libncurses++w.a
mkdir -v       /usr/share/doc/ncurses-6.2
cp -v -R doc/* /usr/share/doc/ncurses-6.2
popd



#8.29. Sed-4.8
pushd sed-4.8
./configure --prefix=/usr --bindir=/bin
make
make html

#chown -Rv tester .
#su tester -c "PATH=$PATH make check"

make install
install -d -m755           /usr/share/doc/sed-4.8
install -m644 doc/sed.html /usr/share/doc/sed-4.8
popd



#8.30. Psmisc-23.4
pushd psmisc-23.4
./configure --prefix=/usr
make
make install
mv -v /usr/bin/fuser   /bin
mv -v /usr/bin/killall /bin
popd



#8.31. Gettext-0.21
rm gettext-0.21 -rf
tar xvf /sources/gettext-0.21.tar.xz
pushd gettext-0.21
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/gettext-0.21
make
#make check
make install
chmod -v 0755 /usr/lib/preloadable_libintl.so
popd



#8.32. Bison-3.7.5
pushd bison-3.7.5
./configure --prefix=/usr --docdir=/usr/share/doc/bison-3.7.5
make
#make check
make install
popd



#8.33. Grep-3.6
pushd grep-3.6
./configure --prefix=/usr --bindir=/bin
make
#make check
make install
popd



#8.34. Bash-5.1
rm bash-5.1 -rf
tar xvf /sources/bash-5.1.tar.gz
pushd bash-5.1
sed -i  '/^bashline.o:.*shmbchar.h/a bashline.o: ${DEFDIR}/builtext.h' Makefile.in
./configure --prefix=/usr                    \
            --docdir=/usr/share/doc/bash-5.1 \
            --without-bash-malloc            \
            --with-installed-readline
make
#run the tests as the tester user:
#chown -Rv tester .
#su tester << EOF
#PATH=$PATH make tests < $(tty)
#EOF
make install
mv -vf /usr/bin/bash /bin
#replacing the one that is currently being executed):
exec /bin/bash --login +h
popd
