#!/bin/bash

echo '--------------------exporting path-------------------------------------'
export INFOPATH=/opt/rh/devtoolset-9/root/usr/share/info
export LD_LIBRARY_PATH=/opt/rh/devtoolset-9/root/usr/lib64:/opt/rh/devtoolset-9/root/usr/lib:/opt/rh/devtoolset-9/root/usr/lib64/dyninst:/opt/rh/devtoolset-9/root/usr/lib/dyninst:/opt/rh/devtoolset-9/root/usr/lib64:/opt/rh/devtoolset-9/root/usr/lib
export MANPATH=/opt/rh/devtoolset-9/root/usr/share/man::/opt/puppetlabs/puppet/share/man
export PATH=/opt/rh/devtoolset-9/root/usr/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/opt/puppetlabs/bin:/root/bin
export PCP_DIR=/opt/rh/devtoolset-9/root
export PKG_CONFIG_PATH=/opt/rh/devtoolset-9/root/usr/lib64/pkgconfig
export SHLVL=4
export X_SCLS=devtoolset-9
echo '------------------ Install vbox modules------------------'
echo '###########################GCC VERSION############################'
gcc --version
mkdir /tmp/isomount
mount -t iso9660 -o loop /home/vagrant/VBoxGuestAdditions.iso /tmp/isomount
cd /tmp/isomount/
ls -la /tmp/isomount
./VBoxLinuxAdditions.run
cat /var/log/vboxadd-setup.log
hash -r
/sbin/rcvboxadd quicksetup all
umount /tmp/isomount
########################################################################
yum clean all
cd /usr/src/
#rm -f linux-5.14.15.tar.xz
rm -Rf linux-5.14.15

# Install vagrant default key
mkdir -pm 700 /home/vagrant/.ssh
curl -sL https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub -o /home/vagrant/.ssh/authorized_keys
chmod 0600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh


# Remove temporary files
rm -rf /tmp/*
rm  -f /var/log/wtmp /var/log/btmp
rm -rf /var/cache/* /usr/share/doc/*
rm -rf /var/cache/yum
rm -rf /vagrant/home/*.iso
rm  -f ~/.bash_history
history -c

rm -rf /run/log/journal/*

# Fill zeros all empty space
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY
sync

