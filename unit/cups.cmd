set +e
useradd -c "Print Service User" -d /var/spool/cups -g lp -s /bin/false -u 9 lp

groupadd -g 19 lpadmin
set -e
#usermod -a -G lpadmin <username>

sed -i 's#@CUPS_HTMLVIEW@#firefox#' desktop/cups.desktop.in

sed -i '/stat.h/a #include <asm-generic/ioctls.h>' tools/ipptool.c   &&

CC=gcc CXX=g++ \
./configure --libdir=/usr/lib            \
            --with-rcdir=/tmp/cupsinit   \
            --with-system-groups=lpadmin \
            --with-docdir=/usr/share/cups/doc-2.3.3 &&
make

make install &&
rm -rf /tmp/cupsinit &&
ln -svnf ../cups/doc-2.3.3 /usr/share/doc/cups-2.3.3

echo "ServerName /run/cups/cups.sock" > /etc/cups/client.conf

cat > /etc/pam.d/cups << "EOF"
# Begin /etc/pam.d/cups

auth    include system-auth
account include system-account
session include system-session

# End /etc/pam.d/cups
EOF

systemctl enable org.cups.cupsd