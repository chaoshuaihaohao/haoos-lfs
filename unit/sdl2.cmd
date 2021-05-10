case $(uname -m) in
   i?86) patch -Np1 -i $BLFS_SRC_DIR/SDL2-2.0.14-opengl_include_fix-1.patch ;;
esac

./configure --prefix=/usr &&
make

pushd docs  &&
  doxygen   &&
popd

make install              &&
rm -v /usr/lib/libSDL2*.a


install -v -m755 -d        /usr/share/doc/SDL2-2.0.14/html &&
cp -Rv  docs/output/html/* /usr/share/doc/SDL2-2.0.14/html