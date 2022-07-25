#!/bin/bash
# (c) 2022 Redecorating
# Pretend I put the GPLv2 here.

set -euo pipefail

ASAHI_WIFI_BRANCH="bits/080-wifi"
ASAHI_BT_BRANCH="bluetooth-wip"

ARCH_VER=$(curl -s https://archlinux.org/packages/core/x86_64/linux/ | \
	grep "Arch Linux - linux" | \
	tr " " $'\n' | grep arch | cut -d- -f1)

VER=$(echo $ARCH_VER | rev | cut -d. -f2- | rev)
BASE_VER=$(echo $VER | cut -d. -f-2)

if echo $ARCH_VER | grep '\..*\.'>/dev/null; then
	UPSTREAM="stable"
else
    UPSTREAM="torvalds"
fi
UPSTREAM_HASH=$(curl -s "https://git.kernel.org/pub/scm/linux/kernel/git/$UPSTREAM/linux.git/tag/?h=v$VER" | \
	grep "tagged object" | cut -d= -f5 | cut -c-40)

#curl -s https://github.com/torvalds/linux/compare/v${BASE_VER}...AsahiLinux:$ASAHI_WIFI_BRANCH.patch > 8001-asahilinux-wifi-patchset.patch
curl -s https://github.com/AsahiLinux/linux/compare/49017886de14bed3eb47c351f6bd5a984b492ccb...`AsahiLinux:linux:bluetooth-wip > 8002-asahilinux-hci_bcm4377-patchset.patch
curl -s https://github.com/archlinux/linux/compare/$UPSTREAM_HASH...archlinux:v$VER-arch1.patch > 0001-arch-additions.patch

curl -s https://raw.githubusercontent.com/archlinux/svntogit-packages/packages/linux/repos/core-x86_64/PKGBUILD > PKGBUILD.orig
curl -s https://raw.githubusercontent.com/archlinux/svntogit-packages/packages/linux/repos/core-x86_64/config > config


sed -i s/pkgrel=./pkgrel=1/ PKGBUILD
sed -i s/pkgver=.*/pkgver=$VER/ PKGBUILD

updpkgsums

vimdiff PKGBUILD PKGBUILD.orig

makepkg -Cso


git diff
