#!/bin/bash

clear
#Sets the time
read -p "Enter Country " country
read -p "Enter City" city
exec timedatectl set-timezone $country / $city

clear
#Partitions the disks
echo "Find your storage device and remember the name of it"
lsblk
read -p "Enter the storage device name" storage
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
mkdir /mnt/boot
mount /dev/$dev1 /mnt/boot
mount /dev/$dev2 /mnt

clear
#Installs the Operating System and enter the new system with chroot
sudo pacman -Sy archlinux-keyring 
pacstrap /mnt base base-devel linux linux-firmware vim nano
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt /bin/bash 

clear
pacman -Syu
pacman -S networkmanager grub ufw
systemctl enable NetworkManager.service
read -p "Enter the storage device name" storage
grub-install --target=i386-pc /dev/$storage #Change if not using intel
grub-mkconfig -o /boot/grub/grub.cfg
systemctl enable ufw

clear
echo "Uncomment the UTF text for your country and save/exit. Make sure not to be doing it in the example section"
read
nano /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
read-p "enter a name you want for your system" hostname
echo $hostname >> /etc/hostname

clear
ls /usr/share/zoneinfo/America/
read -p "Pick the closest city to you on this list" city
ln -sf /usr/share/zoneinfo/America/$city /etc/localtime
