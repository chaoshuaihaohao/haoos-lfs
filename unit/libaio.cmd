sed -i '/install.*libaio.a/s/^/#/' src/Makefile

make

#make partcheck

make install