sed -i 's%/usr/bin/python%&3%' tests/all-errors-documented.py

PYTHON=/usr/bin/python3 ./configure --prefix=/usr          \
                                    --enable-vala-bindings \
                                    --disable-static       
make

#make check

make install