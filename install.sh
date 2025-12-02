#!/bin/bash
timedatectl
clear
#Partitions the disks
lsblk
read -p "Enter the storage device name you'd like to use: " storage
echo "Configuring partition scheme (swap will not work for this script)"
read
cfdisk /dev/$storage
clear
#Formats the partitions
dev1="${storage}1"
dev2="${storage}2"
mkfs.ext4 /dev/$dev1
mkfs.ext4 /dev/$dev2
clear
#Mounts the disks 
mount /dev/$dev2 /mnt
mkdir /mnt/boot
mount /dev/$dev1 /mnt/boot
clear
#Installs the Operating System and enter the new system with chroot
sudo pacman -Sy archlinux-keyring --noconfirm
pacstrap /mnt base base-devel linux linux-firmware vim nano --noconfirm
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt /bin/bash <<EOF
clear
echo "You are now chrooted into the system"
read </dev/tty
pacman -Syu --noconfirm
pacman -S --noconfirm networkmanager grub ufw
systemctl enable NetworkManager.service
lsblk
read -p "Enter the storage device name, not it's partitions (for example sda, not sda1): " storage </dev/tty
grub-install --target=i386-pc /dev/\$storage #Change if not using Bios
grub-mkconfig -o /boot/grub/grub.cfg
systemctl enable ufw
clear
read -p "The default Locale generated will be en_US.UTF-8, would you like to do something else? (y/n) " localebool
default="en_US.UTF-8"
if [ "$localebool" = "y" ]; then
    read -p "Enter other locale (e.g. en_GB.UTF-8): " locale
    sed -i "s|^#\(${locale}.*\)|\1|" /etc/locale.gen
else
    locale="$default"
    sed -i "s|^#\(${locale}.*\)|\1|" /etc/locale.gen
fi
# Generate the locale
locale-gen
echo "LANG=$locale" > /etc/locale.conf
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
clear
read -p "Enter a name you want for your system: " hostname </dev/tty
echo \$hostname >> /etc/hostname
clear
ls /usr/share/zoneinfo/America/
read -p "Pick the closest city to you on this list: " city </dev/tty
ln -sf /usr/share/zoneinfo/America/\$city /etc/localtime
clear
echo "please enter a root password"
passwd </dev/tty
clear
EOF
echo "Installation complete, you may now reboot the system"
read
