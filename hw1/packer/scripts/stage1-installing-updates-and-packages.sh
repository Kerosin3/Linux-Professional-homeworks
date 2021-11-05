#!/bin/bash

#installing packages
yum install -y https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm
yum install -y epel-release
yum -y install bzip2 wget
yum update -y 
yum -y makecache 
yum -y install ncurses-devel make gcc bc flex bison openssl-devel gcc-c++ 
yum -y install elfutils-libelf-devel dkms
yum -y install rpm-build
yum -y install libmpc-devel mpfr-devel gmp-devel rsync
#----------------installing gcc 4.9.2-for sources---------------------
#cd ~
#curl ftp://ftp.mirrorservice.org/sites/sourceware.org/pub/gcc/releases/gcc-4.9.2/gcc-4.9.2.tar.bz2 -O
#tar xfj gcc-4.9.2.tar.bz2
#cd gcc-4.9.2/
#./configure --disable-multilib --enable-languages=c,c++
#make -j 4
#make install
#echo 'preforming path update'
#hash -r
#gcc --version
#export PATH=/usr/local/bin:$PATH
#export LD_LIBRARY_PATH=/usr/local/lib64:$LD_LIBRARY_PATH
#gcc --version
#cd ..
#rm -Rf gcc-4.9.2
#rm -f gcc-4.9.2.tar.bz2
#----------------downloading gcc----------------------
yum -y install yum-utils centos-release-scl
#yum -y --enablerepo=centos-sclo-rh-testing install devtoolset-10-toolchain 
#echo '----------------soursing gcc------------------'
#yum -y --enable rhel-server-rhscl-7-rpms install devtoolset-9-gcc
yum -y --enablerepo=centos-sclo-rh-testing install devtoolset-9-toolchain devtoolset-9-gcc-c++ devtoolset-9-gcc
echo 'source /opt/rh/devtoolset-9/enable' >> /etc/profile
source /opt/rh/devtoolset-10/enable
export INFOPATH=/opt/rh/devtoolset-9/root/usr/share/info
export LD_LIBRARY_PATH=/opt/rh/devtoolset-9/root/usr/lib64:/opt/rh/devtoolset-9/root/usr/lib:/opt/rh/devtoolset-9/root/usr/lib64/dyninst:/opt/rh/devtoolset-9/root/usr/lib/dyninst:/opt/rh/devtoolset-9/root/usr/lib64:/opt/rh/devtoolset-9/root/usr/lib
export MANPATH=/opt/rh/devtoolset-9/root/usr/share/man::/opt/puppetlabs/puppet/share/man
export PATH=/opt/rh/devtoolset-9/root/usr/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/opt/puppetlabs/bin:/root/bin
export PCP_DIR=/opt/rh/devtoolset-9/root
export PKG_CONFIG_PATH=/opt/rh/devtoolset-9/root/usr/lib64/pkgconfig
export SHLVL=4
export X_SCLS=devtoolset-9
#hash -r
echo '###########################GCC VERSION############################3'
gcc --version
cd /usr/src/
wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.14.15.tar.xz
tar -xf linux-5.14.15.tar.xz
cd linux-5.14.15
cp -v /boot/config-$(uname -r) /usr/src/linux-5.14.15/.config
#change kernel parameters
make olddefconfig
sed -i '/CONFIG_RETPOLINE=y/c\CONFIG_RETPOLINE=n' .config
make prepare
make -j$(nproc) rpm-pkg
make headers_install
#-----------------install rpm-------------------#
#rpm -ivh /root/rpmbuild/RPMS/x86_64/*.rpm
rpm -iUv /root/rpmbuild/RPMS/x86_64/*.rpm
echo '----------------deleting BUILD folder for RPM package------------------------'
rm -Rf /root/rpmbuild/BUILD
grub2-mkconfig -o /boot/grub2/grub.cfg
grub2-set-default 0
yum clean all
shutdown -r now
