nix-install:
	./install.sh install

add-channel:
	nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs

update:
	nix-channel --update

home:
	nix run .#homeConfigurations.default.activationPackage