cat > lib-7.md5 << "EOF"
ce2fb8100c6647ee81451ebe388b17ad  xtrans-1.4.0.tar.bz2
f46572566e2cec801609d25f735285b7  libX11-1.7.0.tar.bz2
f5b48bb76ba327cd2a8dc7a383532a95  libXext-1.3.4.tar.bz2
4e1196275aa743d6ebd3d3d5ec1dff9c  libFS-1.0.8.tar.bz2
76d77499ee7120a56566891ca2c0dbcf  libICE-1.0.10.tar.bz2
87c7fad1c1813517979184c8ccd76628  libSM-1.2.3.tar.bz2
eeea9d5af3e6c143d0ea1721d27a5e49  libXScrnSaver-1.2.3.tar.bz2
b122ff9a7ec70c94dbbfd814899fffa5  libXt-1.2.1.tar.bz2
ac774cff8b493f566088a255dbf91201  libXmu-1.1.3.tar.bz2
6f0ecf8d103d528cfc803aa475137afa  libXpm-3.5.13.tar.bz2
e5e06eb14a608b58746bdd1c0bd7b8e3  libXaw-1.0.13.tar.bz2
07e01e046a0215574f36a3aacb148be0  libXfixes-5.0.3.tar.bz2
3fa0841ea89024719b20cd702a9b54e0  libXcomposite-0.4.5.tar.bz2
802179a76bded0b658f4e9ec5e1830a4  libXrender-0.9.10.tar.bz2
9b9be0e289130fb820aedf67705fc549  libXcursor-1.2.0.tar.bz2
e3f554267a7a04b042dc1f6352bd6d99  libXdamage-1.1.5.tar.bz2
6447db6a689fb530c218f0f8328c3abc  libfontenc-1.1.4.tar.bz2
00516bed7ec1453d56974560379fff2f  libXfont2-2.0.4.tar.bz2
4a433c24627b4ff60a4dd403a0990796  libXft-2.3.3.tar.bz2
62c4af0839072024b4b1c8cbe84216c7  libXi-1.7.10.tar.bz2
0d5f826a197dae74da67af4a9ef35885  libXinerama-1.1.4.tar.bz2
18f3b20d522f45e4dadd34afb5bea048  libXrandr-1.5.2.tar.bz2
5d6d443d1abc8e1f6fc1c57fb27729bb  libXres-1.2.0.tar.bz2
ef8c2c1d16a00bd95b9fdcef63b8a2ca  libXtst-1.2.3.tar.bz2
210b6ef30dda2256d54763136faa37b9  libXv-1.0.11.tar.bz2
3569ff7f3e26864d986d6a21147eaa58  libXvMC-1.0.12.tar.bz2
0ddeafc13b33086357cfa96fae41ee8e  libXxf86dga-1.1.5.tar.bz2
298b8fff82df17304dfdb5fe4066fe3a  libXxf86vm-1.1.4.tar.bz2
d2f1f0ec68ac3932dd7f1d9aa0a7a11c  libdmx-1.1.4.tar.bz2
b34e2cbdd6aa8f9cc3fa613fd401a6d6  libpciaccess-0.16.tar.bz2
dd7e1e946def674e78c0efbc5c7d5b3b  libxkbfile-1.1.0.tar.bz2
42dda8016943dc12aff2c03a036e0937  libxshmfence-1.3.tar.bz2
EOF

mkdir lib 
pushd lib 
#grep -v '^#' ../lib-7.md5 | awk '{print $2}' | wget -i- -c \
#    -B https://www.x.org/pub/individual/lib/ 
#md5sum -c ../lib-7.md5


for package in $(grep -v '^#' ../lib-7.md5 | awk '{print $2}')
do
  packagedir=${package%.tar.bz2}
  tar -xf /lfs/Xorg-Libraries/$package
  pushd $packagedir
  docdir="--docdir=$XORG_PREFIX/share/doc/$packagedir"
  case $packagedir in
    libICE* )
      ./configure $XORG_CONFIG $docdir ICE_LIBS=-lpthread
    ;;

    libXfont2-[0-9]* )
      ./configure $XORG_CONFIG $docdir --disable-devel-docs
    ;;

    libXt-[0-9]* )
      ./configure $XORG_CONFIG $docdir \
                  --with-appdefaultdir=/etc/X11/app-defaults
    ;;

    * )
      ./configure $XORG_CONFIG $docdir
    ;;
  esac
  make
  #make check 2>&1 | tee ../$packagedir-make_check.log
  make install
  popd
  rm -rf $packagedir
  /sbin/ldconfig
done


ln -sfv $XORG_PREFIX/lib/X11 /usr/lib/X11 
ln -sfv $XORG_PREFIX/include/X11 /usr/include/X11

popd  #lib