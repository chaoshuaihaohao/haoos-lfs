sed -i '/LIBPOSTFIX="64"/s/64//' configure.ac &&

autoreconf                &&
./configure --prefix=/usr \
            --disable-php \
            PS2PDF=true   &&
make

make install -j1

ln -svf /usr/share/graphviz/doc /usr/share/doc/graphviz-2.44.1
