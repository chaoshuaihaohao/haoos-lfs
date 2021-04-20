#!/bin/bash
set -e
#Part IV. Building the LFS System
if [ `id -u` != 0 ];then
        echo Permission delay, Please run as root!
        exit
fi
#Chapter 8. Installing Basic System Software

if [ -n $JOBS ];then
        JOBS=`grep -c ^processor /proc/cpuinfo 2>/dev/null`
        if [ ! $JOBS ];then
                JOBS="1"
        fi
fi
export MAKEFLAGS=-j$JOBS

export LFS_SRC_DIR=$LFS/sources/lfs-sources

pushd /lfs

#8.35. Libtool-2.4.6
pushd libtool-2.4.6
./configure --prefix=/usr
make
#make check
make install
rm -fv /usr/lib/libltdl.a
popd

#8.36. GDBM-1.19
pushd gdbm-1.19
./configure --prefix=/usr    \
            --disable-static \
            --enable-libgdbm-compat
make
#make check
make install
popd

#8.37. Gperf-3.1
pushd gperf-3.1
./configure --prefix=/usr --docdir=/usr/share/doc/gperf-3.1
make
#make -j1 check
make install
popd

#8.38. Expat-2.2.10
pushd expat-2.2.10
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/expat-2.2.10
make
#make check
make install
install -v -m644 doc/*.{html,png,css} /usr/share/doc/expat-2.2.10
popd

#8.39. Inetutils-2.0
pushd inetutils-2.0
./configure --prefix=/usr        \
            --localstatedir=/var \
            --disable-logger     \
            --disable-whois      \
            --disable-rcp        \
            --disable-rexec      \
            --disable-rlogin     \
            --disable-rsh        \
            --disable-servers
make
#make check
make install
mv -v /usr/bin/{hostname,ping,ping6,traceroute} /bin
mv -v /usr/bin/ifconfig /sbin
popd

#8.40. Perl-5.32.1
rm perl-5.32.1 -rf
tar xf $LFS_SRC_DIR/perl-5.32.1.tar.xz
pushd perl-5.32.1
export BUILD_ZLIB=False
export BUILD_BZIP2=0
sh Configure -des                                         \
             -Dprefix=/usr                                \
             -Dvendorprefix=/usr                          \
             -Dprivlib=/usr/lib/perl5/5.32/core_perl      \
             -Darchlib=/usr/lib/perl5/5.32/core_perl      \
             -Dsitelib=/usr/lib/perl5/5.32/site_perl      \
             -Dsitearch=/usr/lib/perl5/5.32/site_perl     \
             -Dvendorlib=/usr/lib/perl5/5.32/vendor_perl  \
             -Dvendorarch=/usr/lib/perl5/5.32/vendor_perl \
             -Dman1dir=/usr/share/man/man1                \
             -Dman3dir=/usr/share/man/man3                \
             -Dpager="/usr/bin/less -isR"                 \
             -Duseshrplib                                 \
             -Dusethreads
make
#make test
make install
unset BUILD_ZLIB BUILD_BZIP2
popd

#8.41. XML::Parser-2.46
pushd XML-Parser-2.46
perl Makefile.PL
make
#make test
make install
popd

#8.42. Intltool-0.51.0
pushd intltool-0.51.0
sed -i 's:\\\${:\\\$\\{:' intltool-update.in
./configure --prefix=/usr
make
#make check
make install
install -v -Dm644 doc/I18N-HOWTO /usr/share/doc/intltool-0.51.0/I18N-HOWTO
popd

#8.43. Autoconf-2.71
pushd autoconf-2.71
./configure --prefix=/usr
make
#make check
make install
popd

#8.44. Automake-1.16.3
pushd automake-1.16.3
sed -i "s/''/etags/" t/tags-lisp-space.sh
./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.16.3
make
#make -j4 check
make install
popd

#8.45. Kmod-28
pushd kmod-28
./configure --prefix=/usr          \
            --bindir=/bin          \
            --sysconfdir=/etc      \
            --with-rootlibdir=/lib \
            --with-xz              \
            --with-zstd            \
            --with-zlib
make
make install

for target in depmod insmod lsmod modinfo modprobe rmmod; do
  ln -sfv ../bin/kmod /sbin/$target
done

ln -sfv kmod /bin/lsmod
popd

#8.46. Libelf from Elfutils-0.183
pushd elfutils-0.183
./configure --prefix=/usr                \
            --disable-debuginfod         \
            --enable-libdebuginfod=dummy \
            --libdir=/lib
make
#make check
make -C libelf install
install -vm644 config/libelf.pc /usr/lib/pkgconfig
rm /lib/libelf.a
popd

#8.47. Libffi-3.3
pushd libffi-3.3
./configure --prefix=/usr --disable-static --with-gcc-arch=native
make
#make check
make install
popd

#8.48. OpenSSL-1.1.1j
pushd openssl-1.1.1j
./config --prefix=/usr         \
         --openssldir=/etc/ssl \
         --libdir=lib          \
         shared                \
         zlib-dynamic
make
#make test
sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
make MANSUFFIX=ssl install
mv -v /usr/share/doc/openssl /usr/share/doc/openssl-1.1.1j
cp -vfr doc/* /usr/share/doc/openssl-1.1.1j
popd

#8.49. Python-3.9.2
pushd Python-3.9.2
./configure --prefix=/usr       \
            --enable-shared     \
            --with-system-expat \
            --with-system-ffi   \
            --with-ensurepip=yes
make
#make test
make install
install -v -dm755 /usr/share/doc/python-3.9.2/html

tar --strip-components=1  \
    --no-same-owner       \
    --no-same-permissions \
    -C /usr/share/doc/python-3.9.2/html \
    -xvf $LFS_SRC_DIR/python-3.9.2-docs-html.tar.bz2
popd

#8.50. Ninja-1.10.2
pushd ninja-1.10.2
export NINJAJOBS=4
sed -i '/int Guess/a \
  int   j = 0;\
  char* jobs = getenv( "NINJAJOBS" );\
  if ( jobs != NULL ) j = atoi( jobs );\
  if ( j > 0 ) return j;\
' src/ninja.cc
python3 configure.py --bootstrap
#To test the results, issue:
#./ninja ninja_test
#./ninja_test --gtest_filter=-SubprocessTest.SetWithLots
install -vm755 ninja /usr/bin/
install -vDm644 misc/bash-completion /usr/share/bash-completion/completions/ninja
install -vDm644 misc/zsh-completion  /usr/share/zsh/site-functions/_ninja
popd

#8.51. Meson-0.57.1
pushd meson-0.57.1
python3 setup.py build
python3 setup.py install --root=dest
cp -rv dest/* /
popd

#8.52. Coreutils-8.32
rm coreutils-8.32 -rf
tar xf $LFS_SRC_DIR/coreutils-8.32.tar.xz
pushd coreutils-8.32
patch -Np1 -i $LFS_SRC_DIR/coreutils-8.32-i18n-1.patch
sed -i '/test.lock/s/^/#/' gnulib-tests/gnulib.mk
autoreconf -fiv
FORCE_UNSAFE_CONFIGURE=1 ./configure \
            --prefix=/usr            \
            --enable-no-install-program=kill,uptime
make
make NON_ROOT_USERNAME=tester check-root
echo "dummy:x:102:tester" >> /etc/group
#chown -Rv tester . 
#su tester -c "PATH=$PATH make RUN_EXPENSIVE_TESTS=yes check"
sed -i '/dummy/d' /etc/group
make install
mv -v /usr/bin/{cat,chgrp,chmod,chown,cp,date,dd,df,echo} /bin
mv -v /usr/bin/{false,ln,ls,mkdir,mknod,mv,pwd,rm} /bin
mv -v /usr/bin/{rmdir,stty,sync,true,uname} /bin
mv -v /usr/bin/chroot /usr/sbin
mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
sed -i 's/"1"/"8"/' /usr/share/man/man8/chroot.8
mv -v /usr/bin/{head,nice,sleep,touch} /bin
popd

#8.53. Check-0.15.2
pushd check-0.15.2
./configure --prefix=/usr --disable-static
make
#make check
make docdir=/usr/share/doc/check-0.15.2 install
popd

#8.54. Diffutils-3.7
rm  diffutils-3.7 -rf
tar xf $LFS_SRC_DIR/diffutils-3.7.tar.xz
pushd diffutils-3.7
./configure --prefix=/usr
make
#make check
make install
popd

#8.55. Gawk-5.1.0
pushd gawk-5.1.0
sed -i 's/extras//' Makefile.in
./configure --prefix=/usr
make
#make check
make install
mkdir -v /usr/share/doc/gawk-5.1.0
cp    -v doc/{awkforai.txt,*.{eps,pdf,jpg}} /usr/share/doc/gawk-5.1.0
popd

#8.56. Findutils-4.8.0
rm findutils-4.8.0 -rf
tar xf $LFS_SRC_DIR/findutils-4.8.0.tar.xz
pushd findutils-4.8.0
./configure --prefix=/usr --localstatedir=/var/lib/locate
make
#To test the results, issue:
#chown -Rv tester .
#su tester -c "PATH=$PATH make check"
make install
mv -v /usr/bin/find /bin
sed -i 's|find:=${BINDIR}|find:=/bin|' /usr/bin/updatedb
popd

#8.57. Groff-1.22.4
pushd groff-1.22.4
#PAGE=<paper_size> ./configure --prefix=/usr
PAGE=A4 ./configure --prefix=/usr
make -j1
make install
popd

#8.58. GRUB-2.04
pushd grub-2.04
sed "s/gold-version/& -R .note.gnu.property/" \
    -i Makefile.in grub-core/Makefile.in
./configure --prefix=/usr          \
            --sbindir=/sbin        \
            --sysconfdir=/etc      \
            --disable-efiemu       \
            --disable-werror
make
make install
mv -v /etc/bash_completion.d/grub /usr/share/bash-completion/completions
popd

#8.59. Less-563
pushd less-563
./configure --prefix=/usr --sysconfdir=/etc
make
make install
popd

#8.60. Gzip-1.10
rm -rf gzip-1.10
tar xf $LFS_SRC_DIR/gzip-1.10.tar.xz
pushd gzip-1.10
./configure --prefix=/usr
make
#make check
make install
mv -v /usr/bin/gzip /bin
popd

#8.61. IPRoute2-5.10.0
pushd iproute2-5.10.0
sed -i /ARPD/d Makefile
rm -fv man/man8/arpd.8
sed -i 's/.m_ipt.o//' tc/Makefile
make
make DOCDIR=/usr/share/doc/iproute2-5.10.0 install
popd

#8.62. Kbd-2.4.0
rm kbd-2.4.0 -rf
tar xf $LFS_SRC_DIR/kbd-2.4.0.tar.xz
pushd kbd-2.4.0
patch -Np1 -i $LFS_SRC_DIR/kbd-2.4.0-backspace-1.patch
sed -i '/RESIZECONS_PROGS=/s/yes/no/' configure
sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in
./configure --prefix=/usr --disable-vlock
make
#make check
make install
mkdir -v            /usr/share/doc/kbd-2.4.0
cp -R -v docs/doc/* /usr/share/doc/kbd-2.4.0
popd

#8.63. Libpipeline-1.5.3
pushd libpipeline-1.5.3
./configure --prefix=/usr
make
#make check
make install
popd

#8.64. Make-4.3
pushd make-4.3
./configure --prefix=/usr
make
#make check
make install
popd

#8.65. Patch-2.7.6
rm -rf patch-2.7.6
tar xf $LFS_SRC_DIR/patch-2.7.6.tar.xz
pushd patch-2.7.6
./configure --prefix=/usr
make
#make check
make install
popd

#8.66. Man-DB-2.9.4
pushd man-db-2.9.4
./configure --prefix=/usr                        \
            --docdir=/usr/share/doc/man-db-2.9.4 \
            --sysconfdir=/etc                    \
            --disable-setuid                     \
            --enable-cache-owner=bin             \
            --with-browser=/usr/bin/lynx         \
            --with-vgrind=/usr/bin/vgrind        \
            --with-grap=/usr/bin/grap            \
            --with-systemdtmpfilesdir=           \
            --with-systemdsystemunitdir=
make
#make check
make install
popd

#8.67. Tar-1.34
pushd tar-1.34
FORCE_UNSAFE_CONFIGURE=1  \
./configure --prefix=/usr \
            --bindir=/bin
make
#make check
make install
make -C doc install-html docdir=/usr/share/doc/tar-1.34
popd

#8.68. Texinfo-6.7
pushd texinfo-6.7
./configure --prefix=/usr
make
#make check
make install
make TEXMF=/usr/share/texmf install-tex

#pushd /usr/share/info
#  rm -v dir
#  for f in *
#    do install-info $f dir 2>/dev/null
#  done
#popd #/usr/share/info
popd

#8.69. Vim-8.2.2433
pushd vim-8.2.2433
echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h
./configure --prefix=/usr
make
#chown -Rv tester .
#su tester -c "LANG=en_US.UTF-8 make -j1 test" &> vim-test.log
make install
ln -sfv vim /usr/bin/vi
for L in  /usr/share/man/{,*/}man1/vim.1; do
    ln -sv vim.1 $(dirname $L)/vi.1
done
ln -sfv ../vim/vim82/doc /usr/share/doc/vim-8.2.2433
cat > /etc/vimrc << "EOF"
" Begin /etc/vimrc

" Ensure defaults are set before customizing settings, not after
source $VIMRUNTIME/defaults.vim
let skip_defaults_vim=1

set nocompatible
set backspace=2
set mouse=
syntax on
if (&term == "xterm") || (&term == "putty")
  set background=dark
endif

" End /etc/vimrc
EOF
popd

#8.70. Systemd-247
rm systemd-247 -rf
tar xf $LFS_SRC_DIR/systemd-247.tar.gz
pushd systemd-247
patch -Np1 -i $LFS_SRC_DIR/systemd-247-upstream_fixes-1.patch
ln -sf /bin/true /usr/bin/xsltproc
tar -xf $LFS_SRC_DIR/systemd-man-pages-247.tar.xz
sed '181,$ d' -i src/resolve/meson.build
sed -i 's/GROUP="render"/GROUP="video"/' rules.d/50-udev-default.rules.in

mkdir -p build
cd       build

LANG=en_US.UTF-8                    \
meson --prefix=/usr                 \
      --sysconfdir=/etc             \
      --localstatedir=/var          \
      -Dblkid=true                  \
      -Dbuildtype=release           \
      -Ddefault-dnssec=no           \
      -Dfirstboot=false             \
      -Dinstall-tests=false         \
      -Dkmod-path=/bin/kmod         \
      -Dldconfig=false              \
      -Dmount-path=/bin/mount       \
      -Drootprefix=                 \
      -Drootlibdir=/lib             \
      -Dsplit-usr=true              \
      -Dsulogin-path=/sbin/sulogin  \
      -Dsysusers=false              \
      -Dumount-path=/bin/umount     \
      -Db_lto=false                 \
      -Drpmmacrosdir=no             \
      -Dhomed=false                 \
      -Duserdb=false                \
      -Dman=true                    \
      -Dmode=release                \
      -Ddocdir=/usr/share/doc/systemd-247 \
      ..
LANG=en_US.UTF-8 ninja
LANG=en_US.UTF-8 ninja install
rm -f /usr/bin/xsltproc
rm -rf /usr/lib/pam.d
systemd-machine-id-setup
systemctl preset-all
systemctl disable systemd-time-wait-sync.service
popd

#8.71. D-Bus-1.12.20
pushd dbus-1.12.20
./configure --prefix=/usr                        \
            --sysconfdir=/etc                    \
            --localstatedir=/var                 \
            --disable-static                     \
            --disable-doxygen-docs               \
            --disable-xml-docs                   \
            --docdir=/usr/share/doc/dbus-1.12.20 \
            --with-console-auth-dir=/run/console \
            --with-system-pid-file=/run/dbus/pid \
            --with-system-socket=/run/dbus/system_bus_socket
make
make install
mv -v /usr/lib/libdbus-1.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libdbus-1.so) /usr/lib/libdbus-1.so
ln -sfv /etc/machine-id /var/lib/dbus
popd

#8.70. Eudev-3.2.10
pushd eudev-3.2.10
./configure --prefix=/usr           \
            --bindir=/sbin          \
            --sbindir=/sbin         \
            --libdir=/usr/lib       \
            --sysconfdir=/etc       \
            --libexecdir=/lib       \
            --with-rootprefix=      \
            --with-rootlibdir=/lib  \
            --enable-manpages       \
            --disable-static
make
mkdir -pv /lib/udev/rules.d
mkdir -pv /etc/udev/rules.d
#make check
make install
tar -xf $LFS_SRC_DIR/udev-lfs-20171102.tar.xz
make -f udev-lfs-20171102/Makefile.lfs install
udevadm hwdb --update
popd

#8.72. Procps-ng-3.3.17
pushd procps-3.3.17
./configure --prefix=/usr                            \
            --exec-prefix=                           \
            --libdir=/usr/lib                        \
            --docdir=/usr/share/doc/procps-ng-3.3.17 \
            --disable-static                         \
            --disable-kill                           \
            --with-systemd
make
#make check
make install
mv -v /usr/lib/libprocps.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libprocps.so) /usr/lib/libprocps.so
popd

#8.73. Util-linux-2.36.2
pushd util-linux-2.36.2
./configure ADJTIME_PATH=/var/lib/hwclock/adjtime   \
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
            --without-systemdsystemunitdir \
            runstatedir=/run
make
#chown -Rv tester .
#su tester -c "make -k check"
make install
popd

#8.74. E2fsprogs-1.46.1
pushd e2fsprogs-1.46.1
rm build -rf
mkdir -v build
pushd       build
../configure --prefix=/usr           \
             --bindir=/bin           \
             --with-root-prefix=""   \
             --enable-elf-shlibs     \
             --disable-libblkid      \
             --disable-libuuid       \
             --disable-uuidd         \
             --disable-fsck
make
#make check
make install
rm -fv /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a
gunzip -v /usr/share/info/libext2fs.info.gz
install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info
makeinfo -o      doc/com_err.info ../lib/et/com_err.texinfo
install -v -m644 doc/com_err.info /usr/share/info
install-info --dir-file=/usr/share/info/dir /usr/share/info/com_err.info
popd #build
popd


popd #/lfs
