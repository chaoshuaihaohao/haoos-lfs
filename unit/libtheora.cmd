sed -i 's/png_\(sizeof\)/\1/g' examples/png2theora.c &&
./configure --prefix=/usr --disable-static &&
make
#make check
make install
cd examples/.libs &&
for E in *; do
  install -v -m755 $E /usr/bin/theora_${E}
done