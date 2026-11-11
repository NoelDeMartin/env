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
- Apply `custom.css` (see below).

Run it again whenever you change `settings.json` in this repository.

## Custom CSS

`custom.css` is loaded with the [Custom CSS and JS Loader](https://github.com/be5invis/vscode-custom-css) extension, which works by patching VSCode's own files. You can run the following command to apply it:

```sh
./omarchy/scripts/install-vscode-css.sh
```

This takes ownership of VSCode's workbench folder (asking for `sudo` when needed) and applies the same patch as the extension's "Reload Custom CSS and JS" command, which keeps working from within VSCode as well. Restart VSCode to see the changes.

VSCode updates undo the patch, so the script is also linked as an Omarchy `post-update` hook and runs at the end of every `omarchy update`. Run it by hand after changing `custom.css`, or if VSCode was updated in some other way.
