sed -i '/( oxygen/ s/)/scalable )/' CMakeLists.txt

mkdir build &&
cd    build &&

cmake -DCMAKE_INSTALL_PREFIX=/usr -Wno-dev ..

make install