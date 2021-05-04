rm -fv /usr/bin/desktop-file-edit
mkdir build &&
pushd    build &&
meson --prefix=/usr .. &&
ninja
ninja install
install -vdm755 /usr/share/applications &&
update-desktop-database /usr/share/applications
popd