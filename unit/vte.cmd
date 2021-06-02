mkdir build 
cd    build 

meson  --prefix=/usr -Dfribidi=false .. 
ninja

#ninja test

ninja install
rm -v /etc/profile.d/vte.*