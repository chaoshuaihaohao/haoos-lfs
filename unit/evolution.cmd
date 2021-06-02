mkdir build 
cd    build 

cmake -DCMAKE_INSTALL_PREFIX=/usr \
      -DSYSCONF_INSTALL_DIR=/etc  \
      -DENABLE_INSTALLED_TESTS=ON \
      -DENABLE_PST_IMPORT=OFF     \
      -DENABLE_YTNEF=OFF          \
      -DENABLE_CONTACT_MAPS=OFF   \
      -G Ninja .. 
ninja

ninja install