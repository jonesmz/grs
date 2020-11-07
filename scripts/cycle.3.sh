#!/bin/bash -ex

##
# Taken from https://wiki.gentoo.org/wiki/Project:RelEng_GRS on or before Nov 2020.
# Modified for compatibility with other configuration files in this repository.
##

##
# Install debugedit to support splitting debug symbols from files as they are installed.
##
emerge --jobs dev-util/debugedit

USE="build dbus -filecaps" emerge --jobs sys-apps/systemd

##
# Hack hack hack.
# At some point the default use flags, or dependency graph,
# changed to require this "-filecaps" flag to break a cycle.
# Remove the "USE=" part when a more elegant way is discovered.
##
USE="-filecaps" emerge --jobs --keep-going --newuse --changed-deps --changed-slot=y	\
                       --backtrack=3000 --complete-graph --with-bdeps=y --tree		\
                       --binpkg-respect-use=y --binpkg-changed-deps=y --deep		\
                       @system

emerge --jobs --keep-going --newuse --changed-deps --changed-slot=y	\
       --backtrack=3000 --complete-graph --with-bdeps=y --tree		\
       --binpkg-respect-use=y --binpkg-changed-deps=y --deep		\
       @system

emerge --depclean
