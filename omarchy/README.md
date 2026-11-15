# Omarchy

Just run the following script:

```sh
./omarchy/scripts/install.sh
```

To apply changes to config files, run:

```sh
hyprctl reload && hyprctl configerrors
```

## Per-computer overrides

Machine-specific overrides can be placed in a gitignored `omarchy/local/.env` file, which `install-overrides.sh` reads automatically if present. Both `omarchy/local/` and `omarchy/local/.env` are optional — if neither exists, everything still runs using the defaults below.

| Variable | Description | Accepted values | Default |
| --- | --- | --- | --- |
| `MONITOR_SCALE` | Hyprland monitor scale in `~/.config/hypr/monitors.lua` | Number (e.g. `1.5`) or `auto` | `"auto"` (Omarchy default, left untouched if unset) |
| `GDK_SCALE` | `GDK_SCALE` for X11/XWayland apps in `~/.config/hypr/monitors.lua` | Number (e.g. `1`, `2`) | `2` (Omarchy default, left untouched if unset) |
| `MOUSE_SENSITIVITY` | Hyprland `input.sensitivity` via `~/.config/hypr/input.local.lua` | Number from `-1` to `1` | `0` |
