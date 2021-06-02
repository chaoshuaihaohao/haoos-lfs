sed 's@/bin/sh@/bin/sh -l@' -i gnome-session/gnome-session.in

echo 'Slice=-.slice' >> data/gnome-session-restart-dbus.service.in

mkdir build 
cd    build 

meson --prefix=/usr .. 
ninja

ninja install