# SteamOS Deckard Repository

This is an automatically updated mirror of the SteamOS Deckard repository built from the SteamOS source packages found [here](https://holo-packages.steamos.cloud/archlinux-deckard-hotfixes/source/). For more information, see the tool that generates this mirror, [evlav](https://github.com/evlav/evlav).

PKGBUILD URLs pointing to private Valve repositories are replaced with repositories in this mirror.

> [!WARNING]
> This mirror is automatically generated from scratch and updated automatically. **It may have its history regenerated at any time.**

## Building Packages
To build packages in this repository, clone it and run `makepkg` in the directory of the package you want to build.

```bash
git clone https://github.com/evlaV/deckard.git

cd deckard/<package>
makepkg -si
```
