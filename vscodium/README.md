# VSCodium

I use [VSCodium](https://github.com/VSCodium/vscodium) instead of VSCode.

Most of my setup has been inspired by Caleb Porzio's excellent [Make VSCode Awesome](https://makevscodeawesome.com/) course.

## Configuration

Get started with the following commands:

```sh
cp vscodium/settings.json ~/.config/VSCodium/User/settings.json
cp vscodium/keybindings.json ~/.config/VSCodium/User/keybindings.json
sed -i "s|\[projects-path\]|$HOME/workspace|g" ~/.config/VSCodium/User/settings.json
```

## Custom CSS

In order to enable Custom CSS, run the following commands first:

```sh
sudo chown -R $(whoami) "$(which codium)"
sudo chown -R $(whoami) /usr/share/codium
```

Read the [official instructions](https://github.com/be5invis/vscode-custom-css#mac-and-linux-users) to learn more.
