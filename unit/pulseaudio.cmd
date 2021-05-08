mkdir build &&
cd    build &&

meson  --prefix=/usr -Ddatabase=gdbm -Dbluez5=false &&
ninja
#ninja test
ninja install

rm -fv /etc/dbus-1/system.d/pulseaudio-system.conf