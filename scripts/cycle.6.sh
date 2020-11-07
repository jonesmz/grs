#!/bin/bash -ex

source /etc/profile
env-update

emerge --update @world
emerge -1 --ignore-default-opts --jobs --keep-going @preserved-rebuild
emerge --depclean
