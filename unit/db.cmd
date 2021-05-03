sed -i 's/\(__atomic_compare_exchange\)/\1_db/' src/dbinc/atomic.h
cd build_unix                        &&
../dist/configure --prefix=/usr      \
                  --enable-compat185 \
                  --enable-dbm       \
                  --disable-static   \
                  --enable-cxx       &&
make
make docdir=/usr/share/doc/db-5.3.28 install &&

chown -v -R root:root                        \
      /usr/bin/db_*                          \
      /usr/include/db{,_185,_cxx}.h          \
      /usr/lib/libdb*.{so,la}                \
      /usr/share/doc/db-5.3.28