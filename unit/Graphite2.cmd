sed -i '/cmptest/d' tests/CMakeLists.txt

mkdir build &&
pushd    build &&

cmake -DCMAKE_INSTALL_PREFIX=/usr .. &&
make

make docs

make install

install -v -d -m755 /usr/share/doc/graphite2-1.3.14 &&

cp      -v -f    doc/{GTF,manual}.html \
                    /usr/share/doc/graphite2-1.3.14 &&
#cp      -v -f    doc/{GTF,manual}.pdf \
#                    /usr/share/doc/graphite2-1.3.14

popd