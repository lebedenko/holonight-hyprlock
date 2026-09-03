#!/bin/sh
set -eu

root=$(mktemp -d)
trap 'rm -rf "$root"' EXIT HUP INT TERM
bin="$root/bin"
sysfs="$root/sysfs"
mkdir -p "$bin" "$sysfs"
status=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)/scripts/status
export PATH="$bin:/usr/bin:/bin"
export HOLONIGHT_HYPRLOCK_SYSFS_ROOT="$sysfs"
export HOLONIGHT_HYPRLOCK_PASSWD_FILE="$root/passwd"
export HOLONIGHT_HYPRLOCK_NMCLI="$bin/nmcli"
export HOLONIGHT_HYPRLOCK_WPCTL="$bin/wpctl"
export USER=tester

assert_eq() {
    actual=$1 expected=$2 description=$3
    if [ "$actual" != "$expected" ]; then
        printf 'FAIL: %s\nexpected: [%s]\nactual:   [%s]\n' "$description" "$expected" "$actual" >&2
        exit 1
    fi
}

printf 'tester:x:1000:1000:Test User,,,:/home/tester:/bin/sh\n' > "$root/passwd"
assert_eq "$("$status" user)" 'Test User' 'GECOS display name'
printf 'tester:x:1000:1000:R&D <Night>,,,:/home/tester:/bin/sh\n' > "$root/passwd"
assert_eq "$("$status" user)" 'R&amp;D &lt;Night&gt;' 'Pango-safe display name'
printf 'tester:x:1000:1000::/home/tester:/bin/sh\n' > "$root/passwd"
assert_eq "$("$status" user)" 'tester' 'login fallback'

cat > "$bin/nmcli" <<'EOF'
#!/bin/sh
printf 'wifi:connected\nethernet:disconnected\n'
EOF
chmod +x "$bin/nmcli"
assert_eq "$("$status" wifi)" '󰤨' 'connected wifi'
sed -i 's/wifi:connected/wifi:disconnected/' "$bin/nmcli"
assert_eq "$("$status" wifi)" '󰤭' 'disconnected wifi'
rm "$bin/nmcli"
assert_eq "$("$status" wifi)" '' 'missing nmcli'

cat > "$bin/wpctl" <<'EOF'
#!/bin/sh
printf '%s\n' "${WPCTL_OUTPUT:-Volume: 0.20}"
EOF
chmod +x "$bin/wpctl"
assert_eq "$(WPCTL_OUTPUT='Volume: 0.20 [MUTED]' "$status" volume)" '󰖁' 'muted volume'
assert_eq "$(WPCTL_OUTPUT='Volume: 0.20' "$status" volume)" '󰕿 20%' 'low volume'
assert_eq "$(WPCTL_OUTPUT='Volume: 0.50' "$status" volume)" '󰖀 50%' 'medium volume'
assert_eq "$(WPCTL_OUTPUT='Volume: 0.90' "$status" volume)" '󰕾 90%' 'high volume'
rm "$bin/wpctl"
assert_eq "$("$status" volume)" '' 'missing wpctl'

mkdir -p "$sysfs/BAT0" "$sysfs/hidpp_battery_0"
printf 'Battery\n' > "$sysfs/BAT0/type"
printf '82\n' > "$sysfs/BAT0/capacity"
printf 'Discharging\n' > "$sysfs/BAT0/status"
printf 'Battery\n' > "$sysfs/hidpp_battery_0/type"
printf 'Device\n' > "$sysfs/hidpp_battery_0/scope"
printf '10\n' > "$sysfs/hidpp_battery_0/capacity"
assert_eq "$("$status" battery)" '󰁹 82%' 'primary battery and peripheral ignored'
rm -rf "$sysfs/BAT0"
assert_eq "$("$status" battery)" '' 'no system battery'

printf 'status helper tests passed\n'
