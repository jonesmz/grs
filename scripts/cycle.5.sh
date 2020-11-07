#!/bin/bash -ex

source /etc/profile
env-update

emerge --update @world
emerge  -1 --ignore-default-opts --jobs --keep-going @preserved-rebuild
emerge --depclean

emerge sys-kernel/linux-firmware sys-kernel/gentoo-sources sys-kernel/dracut

dracut	--force				\
	--modules base			\
	--modules bash			\
	--modules btrfs			\
	--modules systemd		\
	--modules systemd-initrd	\
	--modules dracut-systemd	\
	--modules udev-rules		\
	--modules fs-lib		\
	--modules shutdown		\
	--filesystems btrfs		\
	--hardlink			\
	--strip				\
	--early-microcode		\
	--xz				\
	--no-kernel			\
	--reproducible			\
	--kver 0			\
	/boot/initramfs.cpio.xz

cp /usr/src/kernel-config /usr/src/linux/.config
cd /usr/src/linux/
make -j`nproc`

cp arch/x86_64/boot/bzImage /boot/kernel-latest-gentoo-r0-0

ln -sf /proc/mounts				/etc/mtab
ln -sf /run/systemd/resolve/resolv.conf		/etc/resolv.conf
ln -sf /usr/share/zoneinfo/America/Chicago	/etc/localtime

##
# This won't work because the /boot/ directory is not a fat32 filesystem.
##
#bootctl --path=/boot/ install

mkdir -p /boot/loader/entries/

cat <<EOF > /boot/loader/loader.conf
default	gentoo
timeout	3
editor	1
EOF

cat <<EOF > /boot/loader/entries/gentoo.conf
title   Gentoo Linux
initrd  /initramfs.cpio.xz
linux   /kernel-latest-gentoo-r0-0
options root=/dev/ram rw
EOF
