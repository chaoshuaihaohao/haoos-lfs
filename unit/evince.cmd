export CFLAGS="$CFLAGS -I/opt/texlive/2020/include" &&
export CXXFLAGS="$CXXFLAGS -I/opt/texlive/2020/include" &&
export LDFLAGS="$LDFLAGS -L/opt/texlive/2020/lib"


mkdir build &&
cd    build &&

meson --prefix=/usr -Dgtk_doc=false .. &&
ninja

ninja install