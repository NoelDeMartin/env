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

Machine-specific overrides can be placed in a gitignored `omarchy/local/.env` file, which `install-overrides.sh` reads automatically if present:

```env
MONITOR_SCALE=1.5
GDK_SCALE=2
```
