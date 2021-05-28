sed -e '/_XData32/s:register long:register _Xconst long:' \
    -i src/video/x11/SDL_x11sym.h &&

./configure --prefix=/usr --disable-static &&

make

make install

#install -v -m755 -d /usr/share/doc/SDL-1.2.15/html &&
#install -v -m644    docs/html/*.html \
#                    /usr/share/doc/SDL-1.2.15/html

#Testing SDL
#cd test &&
#./configure &&
#make
