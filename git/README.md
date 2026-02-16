# Git

Get started with the following commands:

```sh
git config --global core.excludesFile "$HOME/workspace/env/git/.gitignore"
git config --global user.name "Your Name"
git config --global user.email "Your Email"
git config --global core.editor "vim"
git config --global core.commentChar '%'

# Generate key and add it to github settings
gpg --full-generate-key
gpg --list-secret-keys --keyid-format=long
gpg --armor --export {public-key}
git config --global commit.gpgsign true
```
