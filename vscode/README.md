# VSCode

Most of my setup has been inspired by Caleb Porzio's excellent [Make VSCode Awesome](https://makevscodeawesome.com/) course.

## Configuration

Get started with the following command:

```sh
./omarchy/scripts/install-vscode.sh
```

This will:

- Copy `settings.json` into `~/.config/Code/User/`, replacing `[projects-path]` with the parent folder of this repository and keeping the color theme set by Omarchy.
- Link `keybindings.json`, so changes are picked up from this repository.
- Install the extensions listed in `extensions.json`. [Simple Project Switcher](https://github.com/calebporzio/sps) is not in the marketplace, so it is installed from its GitHub release.

Run it again whenever you change `settings.json` in this repository.

## Custom CSS

In order to enable Custom CSS, run the following commands first:

```sh
sudo chown -R $(whoami) "$(which code)"
sudo chown -R $(whoami) /usr/share/code
```

Read the [official instructions](https://github.com/be5invis/vscode-custom-css#mac-and-linux-users) to learn more.
