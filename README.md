# HoloNight Hyprlock

A self-contained system fallback theme for hyprlock 0.9.6 and newer. It uses the fixed HoloNight dark blue palette,
PAM authentication, a bundled wallpaper, and read-only system indicators.

## Build and install

Runtime requirements are hyprlock 0.9.6 or newer, PAM, Inter, Rajdhani, and JetBrainsMono Nerd Font. WirePlumber's
`wpctl` is optional: the volume indicator is hidden when unavailable. Battery state is read from Linux sysfs.

```sh
cmake -S . -B build -DCMAKE_INSTALL_PREFIX=/usr
cmake --build build
ctest --test-dir build --output-on-failure
DESTDIR="$pkgdir" cmake --install build
```

The package installs `/etc/xdg/hypr/hyprlock.conf`, `/usr/libexec/holonight-hyprlock/status`, and theme assets below
`/usr/share/holonight-hyprlock`. Run `hyprlock` normally; PAM remains responsible for authentication. An existing
`~/.config/hypr/hyprlock.conf` takes precedence over the system fallback.

The common workflows are also available through [Task](https://taskfile.dev/):

```sh
task install
task test
```

`task install` builds and installs the production configuration to `/usr` using `sudo`. `task test` runs the
automated suite and then launches hyprlock inside a nested Hyprland window. The nested compositor isolates the lock
from the host session; unlock normally or close its window to finish the test.

## Customization

Copy the installed configuration to `~/.config/hypr/hyprlock.conf` before changing colors, positions, or assets.
The supplied configuration intentionally contains no clickable or state-changing controls. Wi-Fi, volume, layout,
and battery widgets report state only; password submission uses Enter.

## Assets and license

`assets/wallpaper.png` is the approved HoloNight wallpaper supplied for this theme. The visual mockup is a design
reference and is not distributed. `assets/no-avatar.png` is copied from the GPL-3.0-or-later HoloNight Greeter
project (`qml/images/no-avatar.png`) and retains compatible provenance. Status icons are font glyphs, so the package
does not install raster assets for them.

Code, configuration, documentation, and bundled assets are licensed under GPL-3.0-or-later. See `LICENSE`.
