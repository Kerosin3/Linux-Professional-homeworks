#!/bin/bash

#chroot /mnt
echo 'copying mdadm to into /etc directory.....'
cp /etc/mdadm/mdadm.conf /etc/mdadm.conf
export uuid_raid="$(blkid -s UUID -o value /dev/md0)" #exporting uuid
export uuid_boot="$(blkid -s UUID -o value /dev/sdb2)"
echo 'uuid of raid is'  $uuid_raid
echo 'uuid of boot is'  $uuid_boot
echo 'modifying fstab'
echo 'default fstab content is :........................'
cat /etc/fstab
echo '--------------------------------------------'
rm -f /etc/fstab
touch /etc/fstab
grep -q 'boot' /etc/fstab ||  printf '# boot\nUUID=boot_uuid    /boot    ext4    rw,relatime    0    2\n' >> /etc/fstab
sed -i -e "s|boot_uuid|$uuid_boot|" /etc/fstab
grep -q 'main_folder' /etc/fstab ||  printf '# main_folder\nUUID=raid_uuid    /    ext4    defaults    0    2\n' >> /etc/fstab
sed -i -e "s|raid_uuid|$uuid_raid|" /etc/fstab
echo '/swapfile    none    swap    sw    0   0' >> /etc/fstab
echo 'fstab config after change.............................'
cat /etc/fstab
echo 'adding rd.auto ko kernel parameters'
echo 'GRUB_CMDLINE_LINUX="rd.auto=1 rd.shell=1 rd.debug=1"' >> /etc/default/grub
dracut -f --mdadmconf /boot/initramfs-3.10.0-1127.el7.x86_64.img $(uname -r)
#grub2-install --target=x86_64-efi --efi-directory=/boot/efi  --bootloader-id=grub /dev/sdb
#yum -y install kernel
#echo 'now you have to manually edit fstab'
grub2-install --target=i386-pc /dev/sdb
grub2-mkconfig -o /boot/grub2/grub.cfg
#echo '-------make sure you updated sudo password----------!!!!!!!!!!!!!!!!'
#failed to start user login slice scope
#failed to get d-bus connection operation not permitted centos7 vagrant chroot
