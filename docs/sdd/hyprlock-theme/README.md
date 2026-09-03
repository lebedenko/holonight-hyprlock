# HoloNight Hyprlock Theme SDD

Status: Implemented

## Scope and visual contract

This repository owns a data-only hyprlock 0.9.6+ theme matching the external 1672×941 design reference. Every
monitor receives a darkened, softly blurred HoloNight wallpaper and translucent scrim. Centered content comprises a
Rajdhani clock and localized date, circular account avatar, Inter account name, and rounded password field. The
fixed `holonight-dark` palette uses blue/violet borders, cyan authentication feedback, violet Caps Lock feedback,
and red authentication failure feedback.

The AccountsService image `/var/lib/AccountsService/icons/$USER` is layered above the bundled greeter
`no-avatar.png` fallback. The empty password field contains a lock glyph; Enter submits. The bottom glass pill shows
read-only Wi-Fi, volume, `$LAYOUT`, and primary system-battery state. Accessibility, suspend, power, fingerprint,
clickable controls, and runtime palette synchronization are out of scope.

## Interfaces and behavior

`/usr/libexec/holonight-hyprlock/status` accepts exactly `user`, `wifi`, `volume`, or `battery` and prints at most one
Pango-safe line. It reads GECOS, `nmcli`, `wpctl`, or `/sys/class/power_supply`, respectively. Missing or malformed
providers produce an empty indicator and never prevent locking. Device-scoped peripheral batteries are ignored.
Hyprlock uses PAM for authentication and its built-in `$TIME` and `$LAYOUT` values.

## Installation and dependencies

CMake configures absolute paths for a `/usr` production prefix while supporting `DESTDIR` staging. It installs the
configuration to `/etc/xdg/hypr/hyprlock.conf`, assets to `/usr/share/holonight-hyprlock`, and the helper below
`/usr/libexec`. Per-user hyprlock configuration takes precedence. Required runtime dependencies are hyprlock 0.9.6+,
PAM, Inter, Rajdhani, and JetBrainsMono Nerd Font; `nmcli` and `wpctl` are optional.

## Verification record

Automated verification comprises POSIX shell syntax checking, deterministic helper fixtures, CMake/CTest, staged
installation path assertions, config section and safety checks, and PNG format/dimension checks. Manual acceptance
must cover the reference and common 16:9 layouts, multiple monitors, both avatar paths, live indicators, layout and
Caps Lock changes, incorrect-password feedback, successful PAM unlock, and verbose-log resource errors. UI
automation is prohibited by the umbrella policy.
