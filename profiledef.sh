#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="atomic-linux"
iso_label="ATOMIC_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"
iso_publisher="Angelito <angelito@atomic.linux>"
iso_application="Atomic Linux Live ISO"
iso_version="$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y.%m.%d)"
install_dir="arch"
buildmodes=('iso')

bootmodes=('bios.syslinux' 'uefi.systemd-boot')

pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')
bootstrap_tarball_compression=('zstd' '-c' '-T0' '--auto-threads=logical' '--long' '-19')

file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/root"]="0:0:750"
  ["/root/.automated_script.sh"]="0:0:755"
  ["/root/.gnupg"]="0:0:700"
  ["/etc/sudoers.d/live"]="0:0:0440"
  ["/usr/local/bin/atomic-live-user.sh"]="0:0:0755"
)
