mkdir build &&
pushd build &&

meson --prefix=/usr           \
            -Dadmin_group=adm \
            -Dsystemd=true    \
            .. &&
ninja

ninja install

cat > /etc/polkit-1/rules.d/40-adm.rules << "EOF"
polkit.addAdminRule(function(action, subject) {
   return ["unix-group:adm"];
   });
EOF

systemctl enable accounts-daemon
popd