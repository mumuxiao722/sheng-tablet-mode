# sheng-tablet-mode

[中文](README_CN.md)

Deterministic virtual tablet-mode switch for **GNOME auto-rotation** on the
Xiaomi Pad 6S Pro (`sheng`).

The physical `gpio-keys` hall sensor reports `SW_TABLET_MODE=0` in the shipped
DTB, which makes mutter lock into "laptop" posture and permanently disable
auto-rotation. This repository provides the source files for a small
`fake-tablet-mode` service that works around that:

1. a udev rule hides the physical `gpio-keys` switch from libinput,
2. a virtual `uinput` device reports only `SW_TABLET_MODE`,
3. it flips `SW_TABLET_MODE` 0→1 only after the real user session starts,
   which unlocks mutter's panel-orientation management,
4. cover close/open blanking is controlled via
   `org.gnome.Mutter.DisplayConfig` `PowerSaveMode`.

## Prerequisites

- `iio-sensor-proxy` service running normally: the daemon waits for it to
  own the D-Bus name `net.hadess.SensorProxy` before reporting tablet mode.
- `monitor-sensor` reports accelerometer/gyro orientation correctly (run it
  and rotate the device to confirm).
- Python 3 with `python3-evdev`, plus systemd and udev.

## Files

| File                        | Installed to                                  |
| --------------------------- | --------------------------------------------- |
| `fake-tablet-mode`          | `/usr/libexec/fake-tablet-mode`               |
| `fake-tablet-mode.service`  | systemd unit, `Before=gdm.service`            |
| `80-sheng-tablet-mode.rules`| `/usr/lib/udev/rules.d/`                      |
| `10-sheng-tablet-mode.conf` | `/usr/lib/systemd/logind.conf.d/` (`HandleLidSwitch=ignore`) |
| `sheng-tablet-mode.conf`    | `/usr/lib/modules-load.d/` (loads `uinput`)   |

## About

A small daemon that exposes a virtual `SW_TABLET_MODE` switch to GNOME so
auto-rotation works on the Xiaomi Pad 6S Pro (sheng). The physical `gpio-keys`
hall sensor is hidden from libinput and a `uinput` device reports tablet mode
once the real user session starts, unlocking mutter panel-orientation
management. Cover close/open blanks the screen via the mutter D-Bus
`PowerSaveMode` property.

The sources are distro-agnostic (Python 3 + `evdev` + systemd). Package them
for your distribution: map the files from the table above to your distro's
systemd and udev paths. The upstream implementation is NixOS, see
[DotRedstone/nixos-sheng](https://github.com/DotRedstone/nixos-sheng).

## Packaging

Prebuilt packages are published as GitHub Releases, so there is no need to
build or download from elsewhere:

- `sheng-tablet-mode-1.0.0-1.noarch.rpm` – version-independent noarch RPM
  (no `%{dist}`), installs on any Fedora release.
- `sheng-tablet-mode_1.0.0_all.deb` – Debian/Ubuntu package
  (`Depends: python3, python3-evdev`).

Install:

- Debian/Ubuntu: `sudo dpkg -i sheng-tablet-mode_1.0.0_all.deb`, then
  `sudo apt-get install -f` to fill in dependencies.
- Fedora: `sudo dnf install --nogpgcheck ./sheng-tablet-mode-1.0.0-1.noarch.rpm`

A reboot is required after installing for the udev rule, the logind
drop-in, and the systemd unit to take effect.

To build them yourself from this repo:

- `./build-rpm.sh` – run inside a Fedora container/chroot (needs `rpm-build`);
  outputs the RPM in the current directory.
- `./build-deb.sh` – uses `dpkg-deb --root-owner-group`; outputs the `.deb` in
  the current directory.

The Fedora rootfs build in
[fedora-sheng](https://github.com/mumuxiao722/fedora-sheng) fetches the
released RPM when the rootfs is built with **desktop=GNOME**, instead of
building the package itself. `sheng-tablet-mode.spec` lives in this
repository and is used by `build-rpm.sh`.

## Related Projects

- [DotRedstone/nixos-sheng](https://github.com/DotRedstone/nixos-sheng) – Original NixOS implementation (upstream)
- [fedora-sheng](https://github.com/mumuxiao722/fedora-sheng) – Fedora tablet-mode rootfs that consumes the released RPM

## Credits

- **DotRedstone** – for the [nixos-sheng](https://github.com/DotRedstone/nixos-sheng) project, whose `fake-tablet-mode` service and `docs/hall-sensor-rotation.md` debugging notes form the basis of this package

Licensed under the MIT License. See `LICENSE`.