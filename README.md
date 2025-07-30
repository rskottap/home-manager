# Home Manager

Setup dotfiles, configs, shortcuts, preferences etc., via Home Manager.

## Install Nix and Home Manager

Uses the official nix installer:
```bash
make nix-install
sudo reboot
make add-channel
make update
```

## Run HM
See `home.nix`.
Uses prefixes workflow for setting up dotfiles.

```bash
make home
```
