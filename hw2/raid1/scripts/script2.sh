#!/bin/bash	
sestatus
export device='/dev/sdb' #second drive!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
lsblk
#swapoff -v /swapfile
#rm -f /swapfile
#mkdir /var/log/journal
#systemd-tmpfiles --create --prefix /var/log/journal
systemctl restart systemd-journald
echo 'creating boot pairtitions on boot drive sdb'
sgdisk -n 0:0:+1M -t 0:ef02 -c 0:bios-boot $device
sgdisk -n 0:0:+512M -t 0:8300 -c 0:boot $device 
mkfs.ext4 /${device}2
#mkft.fat -F 32 /${device}2
#sgdisk -e $device #backup
echo '---------------creating raid5------------------------'
lsblk
echo '--------------------zeroing superblock----------------'
mdadm --zero-superblock --force /dev/sd{c,d}
wipefs --all --force /dev/sd{c,d}
echo '----------------creating raid5------------------------'
sysctl -w dev.raid.speed_limit_min=500000
sysctl -w dev.raid.speed_limit_max=5000000
echo 'disk syncing........................'
yes y | mdadm --create --verbose --metadata=1.2 --force /dev/md0 -l 1 -n 2 /dev/sd{c,d}
mdadm --wait /dev/md0
cat /proc/mdstat
mkdir -p /etc/mdadm
touch /etc/mdadm/mdadm.conf
#echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
mdadm --detail --scan >> /etc/mdadm/mdadm.conf
mkfs.ext4 /dev/md0
echo '-----------------------moving system---------------------------'
mount /dev/md0 /mnt
mount | grep md0
echo '................copying base folders.........'
mkdir /mnt/boot
echo 'mount boot folder'
mount /dev/sdb2 /mnt/boot
cp /boot/* /mnt/boot/
rsync -ax --delete --exclude=dev  --exclude=/home/*/gfvs --exclude=/lib/modules/*/volatile --exclude=mnt --exclude=proc --exclude=sys  --exclude=boot / /mnt/
echo 'copying system done'

echo '-----------------------disk syncing....----------------------------'
cd /mnt/
set -m
mkdir -p dev/ mnt/ proc/ run/ sys/
#mkdir -p /mnt/sys/dev/block
mount --rbind /sys /mnt/sys/
for i in /lib/modules/*/volatile ; do mkdir -p /mnt/$i ; done
mount --rbind /dev /mnt/dev
mount --rbind /proc /mnt/proc
echo '-----------------------executing chrooting script-----------------------------'
cd /home/vagrant
wget https://raw.githubusercontent.com/Kerosin3/linux_hw/main/hw2/raid1/chrooting.sh
chmod +x chrooting.sh
cp chrooting.sh /mnt/home/vagrant/
#./chrooting.sh

