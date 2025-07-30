# Home Manager

Setup dotfiles, configs, shortcuts, preferences etc., via Home Manager.

## Install Nix and Home Manager

Uses the official nix installer:
```bash
./install-nix-package-manager.sh install
sudo reboot
./install-nix-package-manager.sh channel
./install-nix-package-manager.sh home-manager
```

## Run HM
See `home.nix`.
Uses prefixes workflow for setting up dotfiles.

```bash
home-manager switch --flake .
```
