#!/bin/sh
set -eu

for dependency in Hyprland hyprlock; do
    command -v "$dependency" >/dev/null 2>&1 || {
        printf 'Missing required command: %s\n' "$dependency" >&2
        exit 1
    }
done

[ -n "${WAYLAND_DISPLAY:-}" ] || {
    printf 'A running Wayland session is required for nested Hyprland.\n' >&2
    exit 1
}

source_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
preview_root=$(mktemp -d)
trap 'rm -rf "$preview_root"' EXIT HUP INT TERM

cmake -S "$source_dir" -B "$preview_root/build" \
    -DBUILD_TESTING=OFF \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DHOLONIGHT_HYPRLOCK_DATA_DIR="$source_dir/assets" \
    -DHOLONIGHT_HYPRLOCK_HELPER="$source_dir/scripts/status" >/dev/null

cat > "$preview_root/hyprland.conf" <<'EOF'
monitor = , 1280x720@60, 0x0, 1

misc {
    disable_hyprland_logo = true
    disable_splash_rendering = true
    force_default_wallpaper = 0
}

input {
    kb_layout = us
}
EOF

cat > "$preview_root/run-lock.sh" <<EOF
#!/bin/sh
hyprlock --verbose --config "$preview_root/build/hyprlock.conf"
hyprctl dispatch exit
EOF
chmod +x "$preview_root/run-lock.sh"

printf '%s\n' 'Starting an isolated nested Hyprland session.'
printf '%s\n' 'Unlock normally, or close the nested window to end the visual test.'
Hyprland --config "$preview_root/hyprland.conf" --locked-cmd "$preview_root/run-lock.sh"
