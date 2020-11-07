#!/bin/bash -ex

##
# Taken from https://wiki.gentoo.org/wiki/Project:RelEng_GRS on or before Nov 2020.
##

emerge --sync

/var/db/repos/gentoo/scripts/bootstrap.sh -q

for d in info doc man zoneinfo
do
    find /usr/share -type d -iname ${d} -exec rm -rf {} +
done
