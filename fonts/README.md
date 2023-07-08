
## fonts

- [nerd-fonts](https://www.nerdfonts.com/)

> Select fonts named with:
> - XXX Regular Nerd Font Complete Mono
> - XXX Italic Nerd Font Complete Mono
> - XXX Bold Nerd Font Complete Mono
> - XXX Bold Italic Nerd Font Complete Mono

- Install

[Install python-fontforge](http://designwithfontforge.com/en-US/Installing_Fontforge.html) and clone repo with following command.

```sh
git clone --filter=blob:none --sparse git@github.com:ryanoasis/nerd-fonts
cd nerd-fonts
git sparse-checkout add font-patcher # Ignore this line if font-patcher has been existed
git sparse-checkout add src/glyphs
git sparse-checkout add bin/scripts
```

- Usage

```sh
fontforge -script nerd-fonts/font-patcher -s -c <path-to-font>
```
