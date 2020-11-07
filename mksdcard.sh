#!/bin/bash -ev

IMAGEFILE=sdcard.img
SQUASHIMAGE=stage6-amd64-hardened-20180102.squashfs
MOUNTDIR=sdcardwork

truncate -s 8G ${IMAGEFILE}

echo "Created sparse file ${IMAGEFILE}"
echo

DEVICE=`losetup --partscan --find --show ${IMAGEFILE}`

echo "Partitioning ${DEVICE}"
echo

sgdisk -Z ${DEVICE}

sgdisk -n 1:0:+50M -t 1:c12a7328-f81f-11d2-ba4b-00a0c93ec93b -c 1:"EFI System Partition" ${DEVICE}
sgdisk -n 2:0:+1G  -t 2:0fc63daf-8483-4772-8e79-3d69d8477de4 -c 2:"LogFS"                ${DEVICE}
sgdisk -n 3:0:0    -t 3:4f68bce3-e8cd-4db1-96e7-fbcaf984b709 -c 3:"RootFS"               ${DEVICE}

sgdisk -p ${DEVICE}

echo "Partitioned ${DEVICE}"
echo

mkfs -t vfat ${DEVICE}p1
mkfs -t vfat ${DEVICE}p2

echo "Created fat filesystem for uefi system partition on ${DEVICE}p1 and log partition on ${DEVICE}p2"
echo

mbuffer -i ${SQUASHIMAGE} -o ${DEVICE}p3

echo "Copied ${SQUASHIMAGE} onto ${DEVICE}p2"
echo

mkdir -p ${MOUNTDIR}

mount ${DEVICE}p3 ${MOUNTDIR}/
mount ${DEVICE}p1 ${MOUNTDIR}/boot/
cp system/boot/kernel* ${MOUNTDIR}/boot/

echo "Copied kernel to boot partition"
echo

mount ${DEVICE}p2 ${MOUNTDIR}/var/log/

#grub2-install --target=x86_64-efi --efi-directory=${MOUNTDIR}/boot/ --boot-directory=${MOUNTDIR}/boot/ --bootloader-id=grub --no-bootsector --no-nvram --recheck --force ${DEVICE}

#systemd-nspawn --capability=CAP_SYS_ADMIN --directory=${MOUNTDIR} --bind=${DEVICE} --bind=${DEVICE}p1 --bind=${DEVICE}p2 --bind=${DEVICE}p3 grub2-install --target=x86_64-efi --efi-directory=/boot/ --boot-directory=/boot/ --bootloader-id=grub --no-bootsector --no-nvram --recheck --force ${DEVICE}
#systemd-nspawn --capability=CAP_SYS_ADMIN --directory=${MOUNTDIR} --bind=${DEVICE} --bind=${DEVICE}p1 --bind=${DEVICE}p2 --bind=${DEVICE}p3 bootctl --path=/boot/ install


systemd-nspawn --directory=${MOUNTDIR} cp /usr/src/linux/arch/x86_64/boot/bzImage /boot/kernel-latest-gentoo-r0-0
systemd-nspawn --directory=${MOUNTDIR} dracut --force -o caps -o modsign -o network -o kernel-modules -o kernel-network-modules -o cifs -o resume -o rootfs-block -o terminfo -o i18n -o usrmount -o fs-lib -a rescue --xz --no-kernel --nofscks --no-early-microcode --no-kernel --strip --hardlink --reproducible --prelink --kver 0 /boot/initramfs.cpio.xz

systemd-nspawn --directory=${MOUNTDIR} bootctl --path=/boot/ install

systemd-nspawn --directory=${MOUNTDIR} mkdir -p /boot/loader/entries/

#systemd-nspawn --directory=${MOUNTDIR} cat <<EOF > /boot/loader/loader.conf
#default gentoo
#timeout 3
#editor  1
#EOF

#systemd-nspawn --directory=${MOUNTDIR} cat <<EOF > /boot/loader/entries/gentoo.conf
#title   Gentoo Linux
#initrd  /initramfs.cpio.xz
#linux   /kernel-latest-gentoo-r0-0
#options root=/dev/disk/by-label/RootFS rw
#EOF

umount ${MOUNTDIR}/boot/
umount ${MOUNTDIR}/var/log
umount ${MOUNTDIR}/

losetup --detach ${DEVICE}
