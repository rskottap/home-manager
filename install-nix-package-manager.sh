#!/usr/bin/env bash

phase="$1"  # Use correct variable assignment syntax (no spaces around `=`)
if [ "$phase" == "install" ]; then
    # Installation

    # Download installation file
    curl --proto '=https' --tlsv1.2 -sSfL https://nixos.org/nix/install -o nix-install.sh

    # Optionally inspect the script
    # less ./nix-install.sh

    # Make it executable
    chmod +x ./nix-install.sh

    # Run script to start Nix installation
    ./nix-install.sh --daemon

    nix --version
    nix-channel --list
    sudo echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf
    sudo reboot
fi

# if [ "$phase" == "configure" ]; then
#     # Configuration

#     # Enable nix daemon service
#     sudo systemctl enable nix-daemon.service

#     # Add user to nix-users group
#     sudo usermod -aG nix-users "$USER"

#     # Reboot system (optional)
#     echo "Rebooting to apply group changes..."
#     sudo reboot
# fi

 if [ "$phase" == "channel" ]; then
     # Add and update nix channel
     nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs
     nix-channel --update

     # Show version and current channels
     nix --version
     nix-channel --list
fi

if [ "$phase" == "home-manager" ]; then
    # Add home manager channel and update
    nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
    nix-channel --update
    # Install home manager
    nix-shell '<home-manager>' -A install
fi
