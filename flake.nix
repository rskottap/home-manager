{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }: {
    homeConfigurations.ramya = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
      modules = [
        { home-manager.backupFileExtension = "backup"; }
        ./home.nix
      ];
    };

    # For NixOS
    # Export home.nix so other flakes can use it
    nixosModules.default = { config, pkgs, ... }: {
      imports = [ ./home.nix ];
    };
  };
}
