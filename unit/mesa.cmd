patch -Np1 -i $BLFS_SRC_DIR/mesa-20.3.4-add_xdemos-1.patch

sed '1s/python/&3/' -i bin/symbols-check.py
GALLIUM_DRV="i915,iris,nouveau,r600,radeonsi,svga,swrast,virgl"
DRI_DRIVERS="i965,nouveau"


mkdir build &&
cd    build &&
meson --prefix=$XORG_PREFIX          \
      -Dbuildtype=release            \
      -Ddri-drivers=$DRI_DRIVERS     \
      -Dgallium-drivers=$GALLIUM_DRV \
      -Dgallium-nine=false           \
      -Dglx=dri                      \
      -Dosmesa=gallium               \
      -Dvalgrind=disabled            \
      -Dlibunwind=disabled           \
      ..                             &&
unset GALLIUM_DRV DRI_DRIVERS &&
ninja

ninja install

install -v -dm755 /usr/share/doc/mesa-20.3.4 &&
cp -rfv ../docs/* /usr/share/doc/mesa-20.3.4