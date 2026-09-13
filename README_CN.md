# sheng-tablet-mode

[English](README.md)

针对小米平板 6S Pro（`sheng`）**GNOME 自动旋转**的确定性虚拟平板模式开关。

出厂 DTB 中物理 `gpio-keys` 霍尔传感器上报 `SW_TABLET_MODE=0`，导致 mutter
锁定为"笔记本"姿态并永久关闭自动旋转。本仓库提供一个小型
`fake-tablet-mode` 服务绕过该问题的源码文件：

1. udev 规则将物理 `gpio-keys` 开关对 libinput 隐藏；
2. 虚拟 `uinput` 设备只上报 `SW_TABLET_MODE`；
3. 仅在真实用户会话启动后把 `SW_TABLET_MODE` 0→1，解锁 mutter 面板方向管理；
4. 合盖/开盖亮灭屏由 `org.gnome.Mutter.DisplayConfig` `PowerSaveMode` 控制。

## 前置条件

- `iio-sensor-proxy` 服务运行正常：daemon 会先等待其持有 D-Bus 名
  `net.hadess.SensorProxy`，之后才上报平板模式。
- `monitor-sensor` 能正确上报加速度计/陀螺仪方向（运行它并旋转设备确认）。
- 需要 Python 3 及 `python3-evdev`，以及 systemd 与 udev。

## 文件

| 文件                           | 安装位置                                      |
| ------------------------------ | --------------------------------------------- |
| `fake-tablet-mode`             | `/usr/libexec/fake-tablet-mode`               |
| `fake-tablet-mode.service`     | systemd 单元，`Before=gdm.service`            |
| `80-sheng-tablet-mode.rules`   | `/usr/lib/udev/rules.d/`                      |
| `10-sheng-tablet-mode.conf`    | `/usr/lib/systemd/logind.conf.d/`（`HandleLidSwitch=ignore`） |
| `sheng-tablet-mode.conf`       | `/usr/lib/modules-load.d/`（加载 `uinput`）   |

## 关于

一个小型守护程序：向 GNOME 暴露虚拟 `SW_TABLET_MODE`，使小米平板 6S Pro
（sheng）自动旋转可用。将物理 `gpio-keys` 霍尔传感器对 libinput 隐藏，待
真实用户会话启动后再上报平板模式，从而解锁 mutter 面板方向管理；合盖/开盖
通过 mutter D-Bus `PowerSaveMode` 控制息屏/亮屏。

源码与发行版无关（Python 3 + `evdev` + systemd），请自行打包：按上表将文件
映射到对应发行版的 systemd 与 udev 路径。上游的 NixOS 实现见
[DotRedstone/nixos-sheng](https://github.com/DotRedstone/nixos-sheng)。

## 打包

预编译包以 GitHub Releases 形式发布，无需自行制作或在别处下载：

- `sheng-tablet-mode-1.0.0-1.noarch.rpm` – 不分版本的 noarch RPM（无
  `%dist` 后缀），任意 Fedora 版本均可安装。
- `sheng-tablet-mode_1.0.0_all.deb` – Debian/Ubuntu 包
  （`Depends: python3, python3-evdev`）。

安装：

- Debian/Ubuntu：`sudo dpkg -i sheng-tablet-mode_1.0.0_all.deb`，再用
  `sudo apt-get install -f` 补全依赖。
- Fedora：`sudo dnf install --nogpgcheck ./sheng-tablet-mode-1.0.0-1.noarch.rpm`

安装完成后需要重启，udev 规则、logind drop-in 与 systemd 单元才会生效。

如需自行在仓库内构建：

- `./build-rpm.sh` – 在 Fedora 容器/chroot 中运行（需 `rpm-build`），产物
  输出到当前目录。
- `./build-deb.sh` – 使用 `dpkg-deb --root-owner-group`，产物输出到当前
  目录。

[fedora-sheng](https://github.com/mumuxiao722/fedora-sheng) 的 rootfs 构建在
选择 **desktop=GNOME** 时，直接 fetch 本仓库 Release 中的 RPM，而不再自行
打包。`sheng-tablet-mode.spec` 就放在本仓库中，由 `build-rpm.sh` 使用。

## 相关项目

- [DotRedstone/nixos-sheng](https://github.com/DotRedstone/nixos-sheng) – 上游的 NixOS 实现
- [fedora-sheng](https://github.com/mumuxiao722/fedora-sheng) – 使用本仓库发布的 RPM 的 Fedora 平板 rootfs 项目

## 致谢

- **DotRedstone** – 感谢其 [nixos-sheng](https://github.com/DotRedstone/nixos-sheng) 项目，其中的 `fake-tablet-mode` 服务与 `docs/hall-sensor-rotation.md` 调试记录，是本工具在小米平板 6S Pro 上实现 GNOME 自动旋转的基础

基于 MIT License，详见 `LICENSE`。