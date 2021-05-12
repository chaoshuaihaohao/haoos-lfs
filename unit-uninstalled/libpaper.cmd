autoreconf -fi                &&
./configure --prefix=/usr     \
            --sysconfdir=/etc \
            --disable-static &&
make

make install &&
mkdir -vp /etc/libpaper.d

cat > /etc/papersize << "EOF"
a4
EOF