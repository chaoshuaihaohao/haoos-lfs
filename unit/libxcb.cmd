CFLAGS="${CFLAGS:--O2 -g} -Wno-error=format-extra-args" ./configure $XORG_CONFIG      \
            --without-doxygen \
            --docdir='${datadir}'/doc/libxcb-1.14 
make
make install -j1
