sed -i 's/^miPointerSpriteFuncRec/extern &/' src/drmmode_display.h

./configure $XORG_CONFIG &&
make

make install