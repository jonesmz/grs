#!/bin/bash -ex

##
# Taken from https://wiki.gentoo.org/wiki/Project:RelEng_GRS on or before Nov 2020.
# Modified for compatibility with other configuration files in this repository.
##

source /etc/profile
env-update

eselect news read all > /dev/null
eselect news purge all

emerge --sync

emerge --jobs --keep-going --tree dev-util/debugedit

USE="build" emerge --jobs --keep-going --newuse --changed-deps --changed-slot=y	\
                   --backtrack=3000 --complete-graph --with-bdeps=y --tree	\
                   --binpkg-respect-use=y --binpkg-changed-deps=y --deep 	\
                   sys-apps/portage app-portage/grs
