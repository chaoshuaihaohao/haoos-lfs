groupadd -g 71 colord 
useradd -c "Color Daemon Owner" -d /var/lib/colord -u 71 \
        -g colord -s /bin/false colord

mv po/fur.po po/ur.po 
sed -i 's/fur/ur/' po/LINGUAS

mkdir build 
pushd build 

meson --prefix=/usr            \
      -Ddaemon_user=colord     \
      -Dvapi=true              \
      -Dsystemd=true           \
      -Dlibcolordcompat=true   \
      -Dargyllcms_sensor=false \
      -Dbash_completion=false  \
      -Ddocs=false             \
      -Dman=false ..           
ninja

ninja install

popd