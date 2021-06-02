sed -e 's/miPointer/extern &/' \
    -i src/drmmode_display.h

./configure $XORG_CONFIG 
make

make install