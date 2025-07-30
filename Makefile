nix-install:
	./install.sh install

add-channel:
	nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs

update:
	nix-channel --update

home:
	nix run github:nix-community/home-manager --experimental-features 'nix-command flakes' -- switch -b backup
	nix run .#homeConfigurations.default.activationPackage