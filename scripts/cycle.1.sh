#!/bin/bash -ex

##
# Taken from https://wiki.gentoo.org/wiki/Project:RelEng_GRS on or before Nov 2020.
# Modified for compatibility with other configuration files in this repository.
##

source /etc/profile
env-update

# Prevent warnings about new items.
eselect news read all > /dev/null
eselect news purge all

# Grab latest package info
emerge --sync

# Acquire tool to build cross compiler
emerge -1 --ignore-default-opts sys-devel/crossdev

# Build cross compiler
crossdev --stable --target aarch64-linux-gnueabi --ov-output /var/db/repos/crossdev

# Set up target profile to let the cross compiler build the right things
rm /usr/aarch64-linux-gnueabi/etc/portage/make.profile
ln -sf /var/db/repos/gentoo/profiles/default/linux/arm64/17.0/systemd /usr/aarch64-linux-gnueabi/etc/portage/make.profile

# Debug edit for compressed debug symbols being split
#aarch64-linux-gnueabi-emerge --jobs --keep-going --tree dev-util/debugedit

# Avoid circular dependency of util-linux on systemd and systemd on util-linux
USE="-systemd -udev" aarch64-linux-gnueabi-emerge --emptytree --tree --jobs --keep-going sys-apps/util-linux


# USE="build"									\
# Build system packages normally now that the circular dep is handled.
	aarch64-linux-gnueabi-emerge						\
		--jobs --keep-going --newuse --changed-deps --changed-slot=y    \
		--backtrack=3000 --complete-graph --with-bdeps=y --tree --deep  \
		--binpkg-respect-use=y --binpkg-changed-deps=y                  \
		@system

# Build user facing packages
aarch64-linux-gnueabi-emerge						\
	--jobs --keep-going --newuse --changed-deps --changed-slot=y    \
	--backtrack=3000 --complete-graph --with-bdeps=y --tree --deep  \
	--binpkg-respect-use=y --binpkg-changed-deps=y                  \
	@world x11-misc/sddm lxqt-base/lxqt-meta
