sed -e 's#l \(gtk-.*\).sgml#& -o \1#' \
    -i docs/{faq,tutorial}/Makefile.in      &&

./configure --prefix=/usr --sysconfdir=/etc &&

make


make install

#Configuring GTK+ 2
cat > ~/.gtkrc-2.0 << "EOF"
include "/usr/share/themes/Glider/gtk-2.0/gtkrc"
gtk-icon-theme-name = "hicolor"
EOF

cat > /etc/gtk-2.0/gtkrc << "EOF"
include "/usr/share/themes/Clearlooks/gtk-2.0/gtkrc"
gtk-icon-theme-name = "elementary"
EOF