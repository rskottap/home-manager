home:
	home-manager switch --flake .#default

nix-install:
	sh <(curl -L https://nixos.org/nix/install) --daemon
	nix profile add github:nix-community/home-manager

add-channel:
	nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs

update:
	nix-channel --update