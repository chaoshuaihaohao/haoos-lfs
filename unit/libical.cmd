mkdir build 
pushd    build 

cmake -DCMAKE_INSTALL_PREFIX=/usr  \
      -DCMAKE_BUILD_TYPE=Release   \
      -DSHARED_ONLY=yes            \
      -DICAL_BUILD_DOCS=false      \
      -DGOBJECT_INTROSPECTION=true \
      -DICAL_GLIB_VAPI=true        \
      .. 
make

#make docs

#make test

make install

#install -vdm755 /usr/share/doc/libical-3.0.9/html 
#cp -vr apidocs/html/* /usr/share/doc/libical-3.0.9/html