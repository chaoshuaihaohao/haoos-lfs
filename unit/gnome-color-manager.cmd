sed /subdir\(\'man/d -i meson.build

mkdir build 
cd    build 

meson --prefix=/usr .. 
ninja

ninja install