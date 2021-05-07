mkdir build &&
pushd    build &&

meson  --prefix=/usr       \
       -Dbuildtype=release \
       -Dpackage-origin=http://www.linuxfromscratch.org/blfs/view/svn/ \
       -Dpackage-name="GStreamer 1.18.3 BLFS" &&
ninja
#ninja test
ninja install

popd