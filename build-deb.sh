#!/bin/bash
# Copyright (c) 2026 mumuxiao722
# SPDX-License-Identifier: MIT
#
# Build the .deb package and place the artifact at the repo top level
# (sheng-tablet-mode_1.0.0_all.deb). Uses dpkg-deb (--root-owner-group).
set -e
umask 022

HERE="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$HERE"
STAGE="$HERE/deb/root"

rm -rf "$STAGE"

mkdir -p "$STAGE"/usr/lib/sheng-tablet-mode
install -m 755 "$REPO_ROOT/fake-tablet-mode" "$STAGE/usr/lib/sheng-tablet-mode/fake-tablet-mode"

install -D -m 644 "$REPO_ROOT/fake-tablet-mode.service" "$STAGE/lib/systemd/system/fake-tablet-mode.service"
install -D -m 644 "$REPO_ROOT/80-sheng-tablet-mode.rules" "$STAGE/lib/udev/rules.d/80-sheng-tablet-mode.rules"
install -D -m 644 "$REPO_ROOT/10-sheng-tablet-mode.conf" "$STAGE/lib/systemd/logind.conf.d/10-sheng-tablet-mode.conf"
install -D -m 644 "$REPO_ROOT/sheng-tablet-mode.conf" "$STAGE/usr/lib/modules-load.d/sheng-tablet-mode.conf"

mkdir -p "$STAGE/DEBIAN"
cp "$REPO_ROOT/deb/DEBIAN/control" "$REPO_ROOT/deb/DEBIAN/postinst" \
   "$REPO_ROOT/deb/DEBIAN/prerm" "$REPO_ROOT/deb/DEBIAN/postrm" \
   "$STAGE/DEBIAN/"
chmod 755 "$STAGE/DEBIAN/postinst" "$STAGE/DEBIAN/prerm" "$STAGE/DEBIAN/postrm"

dpkg-deb --build --root-owner-group "$STAGE" "$REPO_ROOT/sheng-tablet-mode_1.0.0_all.deb"

rm -rf "$STAGE"

echo "=== sheng-tablet-mode DEB build complete ==="
ls -la "$REPO_ROOT"/sheng-tablet-mode_1.0.0_all.deb