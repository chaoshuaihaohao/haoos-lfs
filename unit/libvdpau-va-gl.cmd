mkdir build 
cd    build 

cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$XORG_PREFIX .. 
make

#make check

make install

echo "export VDPAU_DRIVER=va_gl" >> /etc/profile.d/xorg.sh