sed -i 's/arm64/amd64/' gdbserver_tests/nlcontrolc.vgtest

sed -i 's|/doc/valgrind||' docs/Makefile.in 

./configure --prefix=/usr \
            --datadir=/usr/share/doc/valgrind-3.16.1 
make

sed -e 's@prereq:.*@prereq: false@' \
    -i {helgrind,drd}/tests/pth_cond_destroy_busy.vgtest

make install