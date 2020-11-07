#!/bin/bash

##
# Taken from https://wiki.gentoo.org/wiki/Project:RelEng_GRS on or before Nov 2020.
##

for d in /tmp /var/tmp /var/log /usr/src
do
    find ${d} -mindepth 1 -exec rm -rf {} +
done
rm -rf /etc/resolv.conf
