#!/bin/sh
set -eu

cmake_command=$1
source_dir=$2
stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT HUP INT TERM
build_dir="$stage/build"
destdir="$stage/dest"

"$cmake_command" -S "$source_dir" -B "$build_dir" -DBUILD_TESTING=OFF -DCMAKE_INSTALL_PREFIX=/usr >/dev/null
DESTDIR="$destdir" "$cmake_command" --install "$build_dir" >/dev/null

for path in etc/xdg/hypr/hyprlock.conf usr/libexec/holonight-hyprlock/status \
    usr/share/holonight-hyprlock/wallpaper.png usr/share/holonight-hyprlock/no-avatar.png \
    usr/share/doc/holonight-hyprlock/README.md usr/share/doc/holonight-hyprlock/LICENSE
do
    test -f "$destdir/$path" || { echo "missing installed file: $path" >&2; exit 1; }
done

config="$destdir/etc/xdg/hypr/hyprlock.conf"
grep -q 'path = /usr/share/holonight-hyprlock/wallpaper.png' "$config"
grep -q 'path = /var/lib/AccountsService/icons/$USER' "$config"
grep -q '/usr/libexec/holonight-hyprlock/status battery' "$config"
for section in background input-field image shape label; do grep -q "^$section {" "$config"; done
! grep -Eiq 'onclick|systemctl|loginctl|poweroff|reboot|suspend' "$config"
file "$destdir/usr/share/holonight-hyprlock/wallpaper.png" | grep -q 'PNG image data, 1672 x 941'
file "$destdir/usr/share/holonight-hyprlock/no-avatar.png" | grep -q 'PNG image data'
test -x "$destdir/usr/libexec/holonight-hyprlock/status"
printf 'package layout tests passed\n'
