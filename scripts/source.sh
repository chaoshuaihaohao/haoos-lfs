#!/bin/bash
set -e
#Chapter 8
if [ `id -u` != 0 ];then
        echo Permission delay, Please run as root!
        exit
fi

#配置Rust
cat >> /etc/ld.so.conf << EOF
# Begin rustc addition

/opt/rustc/lib

# End rustc addition
EOF

ldconfig

cat > /etc/profile.d/rustc.sh << "EOF"
# Begin /etc/profile.d/rustc.sh

pathprepend /opt/rustc/bin           PATH

# End /etc/profile.d/rustc.sh
EOF

source /etc/profile.d/rustc.sh

cat >> /etc/ld.so.conf << EOF
# Begin Qt addition

/opt/qt5/lib

# End Qt addition
EOF

ldconfig



cat > /etc/profile.d/qt5.sh << "EOF"
# Begin /etc/profile.d/qt5.sh

QT5DIR=/opt/qt5

pathappend $QT5DIR/bin           PATH
pathappend $QT5DIR/lib/pkgconfig PKG_CONFIG_PATH

export QT5DIR

# End /etc/profile.d/qt5.sh
EOF

source /etc/profile.d/qt5.sh
