install  -v -m700 -d /var/lib/sshd &&
chown    -v root:sys /var/lib/sshd &&

groupadd -g 50 sshd        &&
useradd  -c 'sshd PrivSep' \
         -d /var/lib/sshd  \
         -g sshd           \
         -s /bin/false     \
         -u 50 sshd
sed -e '/INSTALLKEYS_SH/s/)//' -e '260a\  )' -i contrib/ssh-copy-id
./configure --prefix=/usr                     \
            --sysconfdir=/etc/ssh             \
            --with-md5-passwords              \
            --with-privsep-path=/var/lib/sshd &&
make
make install &&
install -v -m755    contrib/ssh-copy-id /usr/bin     &&

install -v -m644    contrib/ssh-copy-id.1 \
                    /usr/share/man/man1              &&
install -v -m755 -d /usr/share/doc/openssh-8.4p1     &&
install -v -m644    INSTALL LICENCE OVERVIEW README* \
                    /usr/share/doc/openssh-8.4p1
echo "PermitRootLogin no" >> /etc/ssh/sshd_config


echo -e 'y\n' | ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa  #&&
#ssh-copy-id -i ~/.ssh/id_rsa.pub REMOTE_USERNAME@REMOTE_HOSTNAME
echo "PasswordAuthentication no" >> /etc/ssh/sshd_config &&
echo "ChallengeResponseAuthentication no" >> /etc/ssh/sshd_config
#sed 's@d/login@d/sshd@g' /etc/pam.d/login > /etc/pam.d/sshd &&
#chmod 644 /etc/pam.d/sshd &&
#echo "UsePAM yes" >> /etc/ssh/sshd_config
#make install-sshd
