#!/bin/bash -e

# Set the root password to 'root'
echo root:root | chpasswd

# Create a user 'gentoo' and set
# the password to 'gentoo'
useradd -m gentoo
echo gentoo:gentoo | chpasswd

# Make user 'gentoo' a power user
gpasswd -a gentoo disk
gpasswd -a gentoo wheel
gpasswd -a gentoo audio
gpasswd -a gentoo video
gpasswd -a gentoo floppy
gpasswd -a gentoo tape
gpasswd -a gentoo cdrom
gpasswd -a gentoo cdrw
gpasswd -a gentoo usb

gpasswd -a portage wheel

# For the grsec groups.  Make sure these
# match whats in kernel-cofig!
#groupadd -g 9995 graudit
#groupadd -g 9996 grslink
#groupadd -g 9997 grasock
#groupadd -g 9998 grcsock
#groupadd -g 9999 grssock
