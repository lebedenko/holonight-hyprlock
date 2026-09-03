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

cat > "$bin/wpctl" <<'EOF'
#!/bin/sh
printf '%s\n' "${WPCTL_OUTPUT:-Volume: 0.20}"
EOF
chmod +x "$bin/wpctl"
assert_eq "$(WPCTL_OUTPUT='Volume: 0.20 [MUTED]' "$status" volume)" '󰝟 20%' 'muted volume'
assert_eq "$(WPCTL_OUTPUT='Volume: 0.00' "$status" volume)" '󰝟 0%' 'zero volume'
assert_eq "$(WPCTL_OUTPUT='Volume: 0.20' "$status" volume)" '󰕿 20%' 'low volume'
assert_eq "$(WPCTL_OUTPUT='Volume: 0.50' "$status" volume)" '󰖀 50%' 'medium volume'
assert_eq "$(WPCTL_OUTPUT='Volume: 0.90' "$status" volume)" '󰕾 90%' 'high volume'
assert_eq "$(WPCTL_OUTPUT='unexpected output' "$status" volume)" '' 'malformed wpctl output'
assert_eq "$(WPCTL_OUTPUT='Volume: unknown' "$status" volume)" '' 'nonnumeric wpctl volume'
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
printf 'Charging\n' > "$sysfs/BAT0/status"
assert_eq "$("$status" battery)" '󰂄 82%' 'charging battery'
printf 'invalid\n' > "$sysfs/BAT0/capacity"
assert_eq "$("$status" battery)" '' 'malformed battery capacity'
printf '101\n' > "$sysfs/BAT0/capacity"
assert_eq "$("$status" battery)" '' 'out-of-range battery capacity'
rm -rf "$sysfs/BAT0"
assert_eq "$("$status" battery)" '' 'no system battery'

if "$status" wifi >/dev/null 2>&1; then
    printf 'FAIL: obsolete wifi helper command was accepted\n' >&2
    exit 1
fi
if "$status" layout English >/dev/null 2>&1; then
    printf 'FAIL: obsolete layout helper command was accepted\n' >&2
    exit 1
fi

printf 'status helper tests passed\n'
