#!/bin/bash
# Copyright (c) 2026 mumuxiao722
# SPDX-License-Identifier: MIT
#
# Build the version-independent noarch RPM and place the artifact at the repo
# top level (sheng-tablet-mode-1.0.0-1.noarch.rpm). Run inside a Fedora
# container/chroot with rpm-build available (e.g. the DroidSpaces Fedora-44
# container or a podman run against a Fedora image).
#
# Usage: build-rpm.sh [RPMBUILD_TOP]   # default RPMBUILD_TOP=/tmp/rpmbuild
set -e

TOP="${1:-/tmp/rpmbuild}"
REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"

dnf install -y rpm-build tar systemd systemd-rpm-macros

rm -rf "$TOP"
mkdir -p "$TOP"/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

cp "$REPO_ROOT/sheng-tablet-mode.spec" "$TOP/SPECS/"

cd "$REPO_ROOT"
tar -czf "$TOP/SOURCES/sheng-tablet-mode-1.0.0.tar.gz" \
    --exclude=.git \
    --exclude=deb \
    --exclude=sheng-tablet-mode.spec \
    --exclude='*.deb' \
    --exclude='*.rpm' \
    .

rpmbuild --define "_topdir $TOP" -ba "$TOP/SPECS/sheng-tablet-mode.spec"

cp "$TOP"/RPMS/noarch/sheng-tablet-mode-*.rpm "$REPO_ROOT/"

echo "=== sheng-tablet-mode RPM build complete ==="
ls -la "$REPO_ROOT"/sheng-tablet-mode-*.rpm