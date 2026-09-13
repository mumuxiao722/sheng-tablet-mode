# Copyright (c) 2026 mumuxiao722 <zy349931@163.com>
# SPDX-License-Identifier: MIT
#
# Version-independent noarch RPM (no %%{dist}): installs on any Fedora
# release. Built from this repository by build-rpm.sh; published as a
# GitHub Release. The Fedora rootfs build fetches this artifact instead of
# building it.
#
# The fake-tablet-mode daemon is adapted from DotRedstone/nixos-sheng;
# see the script header and README Credits.

%undefine __debug_package
%undefine _debugsource_packages
Name:           sheng-tablet-mode
Version:        1.0.0
Release:        1
Summary:        GNOME auto-rotation fix for Xiaomi Pad 6S Pro

License:        MIT
URL:            https://github.com/mumuxiao722/sheng-tablet-mode
Source0:        %{name}-%{version}.tar.gz

%define _debug_source_subpackages 0
# The fake-tablet-mode daemon is adapted from DotRedstone/nixos-sheng;
# see the script header and README Credits.

BuildArch:      noarch
Requires:       python3
Requires:       python3-evdev

%description
Deterministically expose SW_TABLET_MODE to GNOME so that auto-rotation works
on the Xiaomi Pad 6S Pro (sheng). The physical gpio-keys hall sensor is hidden
from libinput and a virtual uinput switch reports tablet mode once the real
user session starts, which unlocks mutter's panel-orientation management.
Cover close/open blanking is handled via org.gnome.Mutter.DisplayConfig
PowerSaveMode.

GNOME-only: the RPM is only installed in the Fedora rootfs when the GNOME
desktop is selected.

%prep
tar -xf %{SOURCE0}

%install
install -d %{buildroot}/usr/libexec
install -m 755 fake-tablet-mode %{buildroot}/usr/libexec/fake-tablet-mode

install -d %{buildroot}%{_unitdir}
install -m 644 fake-tablet-mode.service %{buildroot}%{_unitdir}/

install -d %{buildroot}/usr/lib/udev/rules.d
install -m 644 80-sheng-tablet-mode.rules %{buildroot}/usr/lib/udev/rules.d/

install -d %{buildroot}/usr/lib/systemd/logind.conf.d
install -m 644 10-sheng-tablet-mode.conf %{buildroot}/usr/lib/systemd/logind.conf.d/

install -d %{buildroot}/usr/lib/modules-load.d
install -m 644 sheng-tablet-mode.conf %{buildroot}/usr/lib/modules-load.d/sheng-tablet-mode.conf

%post
%systemd_post fake-tablet-mode.service

%preun
%systemd_preun fake-tablet-mode.service

%postun
%systemd_postun_with_restart fake-tablet-mode.service

%files
/usr/libexec/fake-tablet-mode
%{_unitdir}/fake-tablet-mode.service
/usr/lib/udev/rules.d/80-sheng-tablet-mode.rules
/usr/lib/systemd/logind.conf.d/10-sheng-tablet-mode.conf
/usr/lib/modules-load.d/sheng-tablet-mode.conf

%changelog
* Thu Sep 10 2026 mumuxiao722 <zy349931@163.com> - 1.0.0-1
- Initial package. Version-independent noarch RPM for any Fedora release.
- fake-tablet-mode daemon adapted from DotRedstone/nixos-sheng.
  See README Credits.