#!/bin/bash -ex

source /etc/profile
env-update

wget -O- https://api.github.com/repos/jonesmz/portageconfig/tarball/master | tar -xzpv -C /etc/portage/ --strip-components 1 --overwrite

ln -sf /etc/portage/amd64-package.accept_keywords /etc/portage/package.accept_keywords
ln -sf /etc/portage/desktop.make.profile /etc/portage/make.profile

touch /etc/portage/make.local

eselect news read all > /dev/null
eselect news purge all

export XDG_DATA_DIRS=/usr/share
USE="-gnuefi -vaapi -gpm" emerge --update @world
emerge --update @world

emerge -1 --ignore-default-opts --jobs @preserved-rebuild

emerge --depclean
