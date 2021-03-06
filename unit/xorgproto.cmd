mkdir build 
pushd    build 
meson --prefix=$XORG_PREFIX -Dlegacy=true .. 
ninja
ninja install 
install -vdm 755 $XORG_PREFIX/share/doc/xorgproto-2020.1 
install -vm 644 ../[^m]*.txt ../PM_spec $XORG_PREFIX/share/doc/xorgproto-2020.1
popd