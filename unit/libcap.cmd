make -C pam_cap

install -v -m755 pam_cap/pam_cap.so /lib/security 
install -v -m644 pam_cap/capability.conf /etc/security

mv -v /etc/pam.d/system-auth{,.bak} 
cat > /etc/pam.d/system-auth << "EOF" 
# Begin /etc/pam.d/system-auth

auth      optional    pam_cap.so
EOF
tail -n +3 /etc/pam.d/system-auth.bak >> /etc/pam.d/system-auth