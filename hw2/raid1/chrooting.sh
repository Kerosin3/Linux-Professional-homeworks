#!/bin/bash

chroot /mnt
export uuid_raid="$(blkid -s UUID -o value /dev/md0)" #exporting uuid
export uuid_boot="$(blkid -s UUID -o value /dev/sdb2)"
echo 'uuid of raid is $uuid_raid'
echo 'uuid of boot is $uuid_boot'
echo 'modifying fstab'
cat /etc/fstab
cat /dev/null > /etc/fstab
grep -q 'boot' /etc/fstab ||  printf '# boot\nUUID=boot_uuid    /boot    vfat    rw,relatime    0    2\n' >> /etc/fstab
sed -i -e "s|boot_uuid|$uuid_boot|" /etc/fstab
grep -q 'main_folder' /etc/fstab ||  printf '# main_folder\nUUID=raid_uuid    /    ext4    defaults    0    2\n' >> /etc/fstab
sed -i -e "s|raid_uuid|$uuid_raid|" /etc/fstab
echo '/swapfile    none    swap    sw    0   0' >> /etc/fstab
cat /etc/fstab
dracut -f /boot/initramfs-3.10.0-1127.el7.x86_64.img $(uname -r)
#grub2-install --target=x86_64-efi --efi-directory=/boot/efi  --bootloader-id=grub /dev/sdb
#yum -y install kernel
grub2-install --target=i386-pc /dev/sdb
grub2-mkconfig -o /boot/grub2/grub.cfg
