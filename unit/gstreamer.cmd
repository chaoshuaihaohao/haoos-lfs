mkdir build &&
pushd    build &&

meson  --prefix=/usr       \
       -Dbuildtype=release \
       -Dgst_debug=false   \
       -Dpackage-origin=http://www.linuxfromscratch.org/blfs/view/svn/ \
       -Dpackage-name="GStreamer 1.18.3 BLFS" &&
ninja
#ninja test
rm -rf /usr/bin/gst-* /usr/{lib,libexec}/gstreamer-1.0
ninja install

popd