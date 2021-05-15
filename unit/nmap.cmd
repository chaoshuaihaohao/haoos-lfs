./configure --prefix=/usr &&
make

sed -i 's/lib./lib/' zenmap/test/run_tests.py

#make check

make install